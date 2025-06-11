// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {OFT} from "lib/solidity-examples/contracts/token/oft/v1/OFT.sol";

contract MyOFT is OFT {
   constructor(
      string memory _name,
      string memory _symbol,
      address _lzEndpoint
   ) OFT(_name, _symbol, _lzEndpoint) {}

   function mint(address to, uint256 amount) external {
      _mint(to, amount);
   }

}