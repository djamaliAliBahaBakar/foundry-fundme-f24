// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import  {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interaction.s.sol";

contract FundMeTestIntegration is Test {
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE =0.1 ether;
    uint256 constant STARTIG_BALANCE = 10 ether;
    uint256 constant GAS_PRICE= 1;
     FundMe public fundMe;

    function setUp() external {
         DeployFundMe deployfundMe  = new DeployFundMe();
         fundMe = deployfundMe.run();
        vm.deal(USER, STARTIG_BALANCE);     
    }

    function testUserCanFund() external{
        FundFundMe funFundMe = new FundFundMe();
        funFundMe.fundFundMe(address(fundMe));

      /*  WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        
        assertEq(address(fundMe).balance, 0);*/

    }
}