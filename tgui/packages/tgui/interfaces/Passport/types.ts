/**
 * @file
 * @copyright 2026
 * @author DisturbHerb (https://github.com/disturbherb)
 * @license ISC
 */

import { BooleanLike } from 'common/react';

export interface PassportData {
  isLeader: BooleanLike;
  isOwner: BooleanLike;
  name: string;
  nationColor: string;
  nationName: string;
  nationShortName: string;
  ownerIcon: string;
  ownerName: string;
  ownerRoleType: string;
}
