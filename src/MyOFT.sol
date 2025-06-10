// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {OFTV2} from "lib/solidity-examples/contracts/token/oft/v2/OFTV2.sol";

contract MyOFT is OFTV2 {
   constructor(
         string memory _name,
        string memory _symbol,
        uint8 _sharedDecimals,
        address _lzEndpoint
   ) OFTV2(_name, _symbol, _sharedDecimals, _lzEndpoint) {}

   function mint(address to, uint256 amount) external {
      _mint(to, amount);
   }

}