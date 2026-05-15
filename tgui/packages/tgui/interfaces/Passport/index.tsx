/**
 * @file
 * @copyright 2026
 * @author DisturbHerb (https://github.com/disturbherb)
 * @license ISC
 */

import { Color } from 'tgui-core/color';
import { Button, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Image } from '../../components';
import { resource } from '../../goonstation/cdn';
import { Window } from '../../layouts';
import { PassportData } from './types';

export const Passport = () => {
  const { data } = useBackend<PassportData>();
  const { name, nationColor, nationName, nationShortName, ownerIcon } = data;

  const nationColorRGBA = Color.fromHex(nationColor);
  const nationColorLighten = Color.fromHex(nationColor);
  nationColorLighten.a = 0.5;
  const backgroundGradientString =
    'linear-gradient(180deg,' +
    nationColorRGBA +
    ' 0%,' +
    nationColorLighten +
    '50%)';

  return (
    <Window title={name} theme="paper" width={400} height={250}>
      <Window.Content
        style={{
          background: backgroundGradientString,
        }}
      >
        <Stack fill vertical>
          <Stack.Item bold fontSize="large">
            <Stack justify="space-between">
              <Stack.Item>PASSPORT</Stack.Item>
              <Stack.Item nowrap>
                {nationShortName ? nationShortName : nationName}
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item align="center" height="100%">
                <Image
                  pixelated
                  src={
                    ownerIcon
                      ? `data:image/png;base64,${ownerIcon}`
                      : resource('images/antagTips/unknown-traitor-image.png')
                  }
                  height="100%"
                />
              </Stack.Item>
              <PassportInfobox />
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const PassportInfobox = () => {
  const { data } = useBackend<PassportData>();
  const { nationName, ownerName, ownerRoleType } = data;

  return (
    <Stack.Item grow>
      <Stack fill vertical justify="center">
        <PassportInfo header="Name" info={ownerName} />
        <PassportInfo header="Nationality" info={nationName} />
        <PassportInfo header="Role" info={ownerRoleType} />
        <PassportInfoButtons />
      </Stack>
    </Stack.Item>
  );
};

interface PassportInfoProps {
  header: string;
  info: string;
}

const PassportInfo = (props: PassportInfoProps) => {
  const { header, info } = props;

  return (
    <Stack.Item>
      <Stack vertical>
        <Stack.Item bold>{header}</Stack.Item>
        <Stack.Item>{info ? info.toUpperCase() : 'N/A'}</Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const PassportInfoButtons = () => {
  const { data } = useBackend<PassportData>();
  const { isLeader, isOwner } = data;

  return (
    <Stack.Item align="center">
      {isOwner ? (
        <Button color="bad">Renounce Citizenship</Button>
      ) : (
        !!isLeader && (
          <Stack>
            <Stack.Item>
              <Button color="bad">Expel Citizen</Button>
            </Stack.Item>
            <Stack.Item>
              <Button color="good">Promote to Leader</Button>
            </Stack.Item>
          </Stack>
        )
      )}
    </Stack.Item>
  );
};
