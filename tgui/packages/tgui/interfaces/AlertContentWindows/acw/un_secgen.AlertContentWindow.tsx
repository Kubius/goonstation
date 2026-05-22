/**
 * @file
 * @copyright 2024
 * @author Original garash2k
 * @author Changes DisturbHerb (https://github.com/disturbherb)
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const UNSecGenContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are the United Nations General Secretary!</h1>
      <img
        src={resource('images/antagTips/unknown-traitor-image.png')}
        className="center"
      />
      <p>
        As an arbiter of international peace and order, your leadership of this
        body places you squarely in the mire of these nations&apos; petty
        disputes and ruinous wars. Call them to dialogue, help them see reason.
        Where words fail, however, some more drastic means may be required to
        maintain the rules-based international order.
      </p>
      <p>
        The nations of the UN may convene in summits held at the UN General
        Assembly; either called by a member nation or summoned by yourself. It
        is here that deals are chiefly hammered out and made known, though it is
        no less important for backdoor channels and private discussions outside
        of these meetings to help steer these nations on the right track.
      </p>
      <p>
        At your disposal are the UN&apos;s Peacekeepers, themselves led by the
        UN Under-Secretary for Peace Operations. This armed force will be
        responsible for enforcing the terms of international treaties. Their
        loyalty to the UN and its mission is unwavering.
      </p>
      <p>
        Your ability to act is ultimately tied to internationally recognized
        consensus and any existing agreements. It would be unbecoming of a
        neutral body to attract the ire of the international community,
        wouldn&apos;t it? You must be fair and just in your dealings, lest your
        legitimacy be shattered in the eyes of the galaxy…
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: "You're the UN Secretary-General!",
  component: UNSecGenContentWindow,
};
