/**
 * @file
 * @copyright 2024
 * @author Original garash2k
 * @author Changes DisturbHerb (https://github.com/disturbherb)
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const NationsLeaderContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a Nation Leader!</h1>
      <img
        src={resource('images/antagTips/unknown-traitor-image.png')}
        className="center"
      />
      <p>
        Congratulations! You have been chosen – by divine right, the mandate of
        the people, or the base force of brutal violence – to lead your
        department&apos;s destiny as an independent nation among the stars!
      </p>

      <p>
        It falls upon you to bestow a name for your petty fiefdom, democratic
        republic, or glorious empire. You may also elect to determine its laws
        and customs, such as the line of succession or decision-making
        mechanisms, as you wish; subject to the discretion of the event admins.
      </p>

      <p>
        Of course, though you may command the respect of your citizens for now,
        it remains on them to go along with your charade. Choose wisely, and
        watch your back! Your leadership&apos;s peril is in your hands!
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: "You're a Nation Leader!",
  component: NationsLeaderContentWindow,
};
