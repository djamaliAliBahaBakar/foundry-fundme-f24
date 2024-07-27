// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import  {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe ;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE =0.1 ether;
    uint256 constant STARTIG_BALANCE = 10 ether;
    uint256 constant GAS_PRICE= 1;
    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        
        DeployFundMe deployfundMe  = new DeployFundMe();
        fundMe = deployfundMe.run();
        vm.deal(USER, STARTIG_BALANCE);
    }

    function testMinimumUsdIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(),  5e18);
    }

    function testOwnerIsMsgOwner() public view {
        //console.log(fundMe.i_owner());
        //console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeddVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version,4);
    }

    function testFundsFailedWithoutEnoughEth() public  {
        vm.expectRevert();
        fundMe.fund();

    }

    function testFundUpdatesDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE} ();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        console.log(amountFunded);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        
        address funder = fundMe.getFunder(0);
        assertEq(funder,USER);

    }

    modifier funded() {
         vm.prank(USER);
        fundMe.fund{value: SEND_VALUE} ();
        _;
    }

    function testOnlyOwnerCanWithdraw() public  funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithrawWithSingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        
        //Acte
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance,0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawWithMultipleFunders() public funded {
        uint160 numbersOfFunders =10;
        uint160 startingFunderIndex = 1;

        for (uint160 i=startingFunderIndex; i < numbersOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        
        //Acte
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
   
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance+startingOwnerBalance == fundMe.getOwner().balance);

    }
}