/**
 * @file
 * @copyright 2024
 * @author Original garash2k
 * @author Changes DisturbHerb (https://github.com/disturbherb)
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const NationsCitizenContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a Citizen!</h1>
      <img
        src={resource('images/antagTips/unknown-traitor-image.png')}
        className="center"
      />
      <p>
        As a proud citizen of your nation, it is up to you and your compatriots
        to wield the nation&apos;s strength against its foes! Might makes right
        aboard this station, make your leader proud!
      </p>
      <p>
        Your leader&apos;s word is the law of this land; long may they reign!
        Though, should your leader&apos;s fair and just hand give way to tyranny
        or weakness, perhaps someone else would do better in their place…
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: "You're a citizen!",
  component: NationsCitizenContentWindow,
};
