/**
 * @file
 * @copyright 2024
 * @author Original garash2k
 * @author Changes DisturbHerb (https://github.com/disturbherb)
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const UNContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are an agent of the United Nations!</h1>
      <img
        src={resource('images/antagTips/unknown-traitor-image.png')}
        className="center"
      />
      <p>
        Whatever your job may be, your overall mission is in carrying out the
        work of the United Nations as a neutral observer, mediator, and enforcer
        of international law.
      </p>
      <p>
        The UN Secretary-General commands your utmost loyalty. Ensure their
        directives are carried out in service of maintaining the rules-based
        international order and stability…
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: "You're a UN Agent!",
  component: UNContentWindow,
};
