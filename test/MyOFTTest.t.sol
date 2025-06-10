// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {OFT} from "lib/solidity-examples/contracts/token/oft/v1/OFT.sol";
import {MyOFT} from "../src/MyOFT.sol";
import {LZEndpointMock} from "lib/solidity-examples/contracts/lzApp/mocks/LZEndpointMock.sol";

contract MyOFTTest is Test {

   MyOFT sourceToken;
   MyOFT destinationToken;
   address user = address(1);
   LZEndpointMock lzEndpointSource;
   LZEndpointMock lzEndpointDestination;



   function setUp() public {
      vm.startPrank(user);
      // Deploy mocks
      lzEndpointSource = new LZEndpointMock(1);     // source chainId = 1
      lzEndpointDestination = new LZEndpointMock(101);  // dest chainId = 101
      // Deploy source and destination
      sourceToken = new MyOFT("CrosschainToken", "CT", address(lzEndpointSource));
      destinationToken = new MyOFT("CrosschainToken", "CT", address(lzEndpointDestination));
      // mint from source to user
      sourceToken.mint(user, 100 ether);

      bytes memory remoteOnDestination = abi.encodePacked(address(destinationToken), address(sourceToken));
      bytes memory remoteOnSource = abi.encodePacked(address(sourceToken), address(destinationToken));

      sourceToken.setTrustedRemote(101, remoteOnDestination);
      destinationToken.setTrustedRemote(1, remoteOnSource);    // 1 = source chain ID

      lzEndpointSource.setDestLzEndpoint(address(destinationToken), address(lzEndpointDestination));
      lzEndpointDestination.setDestLzEndpoint(address(sourceToken), address(lzEndpointSource));
      
      vm.stopPrank();
   }

   function testBasicTransferSimulation() public {
      vm.startPrank(user);

      // Send ETH to the user so they can pay for the mock fee
      vm.deal(user, 1 ether);
      
      // Simulate sending 10 tokens cross-chain (manually trigger receive for test)
      sourceToken.sendFrom{value: 0.1 ether}(
         user,                   // sender
         101,                    // destination chain id example
         abi.encodePacked(user), // destination address encoded
         10 ether,               // amount
         payable(user),          // refund address
         address(0),             // payment address
         bytes("")               // adapter params
      );

      vm.stopPrank();

   }
}