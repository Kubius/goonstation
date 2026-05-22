/**
 * @file
 * @copyright 2024
 * @author Original garash2k
 * @author Changes DisturbHerb (https://github.com/disturbherb)
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const UNPeacekeeperContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a United Nations Peacekeeper!</h1>
      <img
        src={resource('images/antagTips/unknown-traitor-image.png')}
        className="center"
      />
      <p>
        <strong>
          Outside of UN-controlled territory, you are not authorized to enforce
          normal Space Law. Do not arrest, imprison, or harm any person within
          another nation&apos;s territory unless explicitly allowed under
          international law or if you are in immediate danger.
        </strong>
      </p>
      <p>
        The will of the UN must be enforced. Though hope in diplomacy must hold,
        sometimes it is through the power of the Peacekeepers that mere words
        are backed by swift, decisive action.
      </p>
      <p>
        You answer to the UN Secretary-General and the UN Under-Secretary for
        Peace Operations. Maintain the rules-based international order and see
        to it that these petty disputes and wars are approached with an even but
        firm hand…
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: "You're a UN Peacekeeper!",
  component: UNPeacekeeperContentWindow,
};
