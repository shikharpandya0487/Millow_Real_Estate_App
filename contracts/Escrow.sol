//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// It is an Interface for token

// skeleton of smart contract 
interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _id
    ) external;
}

contract Escrow 
{
    //settings in the smart contract 

    // lender 
    // sender 
    // appraiser 


    // data type -> address 
    address public lender ;
    address public inspector ;
    address payable public seller ;
    address public nftAddress ;


    // mapping inside solidity 
    // uint256 is unsigned integer mapped with T/F 


    mapping(uint256 => bool) public isListed;
    mapping(uint256 => uint256) public purchasePrice;
    mapping(uint256 => uint256) public escrowAmount;
    mapping(uint256 => address) public buyer;
    mapping(uint256 => bool) public inspectionPassed;
    mapping(uint256 => mapping(address => bool)) public approval;


    constructor(
        address _nftAddress,
        address payable _seller,
        address _inspector,
        address _lender
    ) {
        nftAddress = _nftAddress;
        seller = _seller;
        inspector = _inspector;
        lender = _lender;
    }



    // move the nft from the wallet to escrow 
    function list( uint256 _nftId,
        address _buyer,
        uint256 _purchasePrice,
        uint256 _escrowAmount) public
    {
        // id of nft
        // The nft goes from the user's wallet to escrow and stays there till the sale is complete

        IERC721(nftAddress).transferFrom(
            msg.sender,
            address(this),
            _nftId
        );  
        
        // it gets the version of the nft 

        // address of the contract that we're coding inside of is fetched using address(this)
        //Here we should also must approve the token while moving token from one wallet to another


        
        isListed[_nftId]=true;
        purchasePrice[_nftId]=_purchasePrice;
        escrowAmount[_nftId]=_escrowAmount;
        buyer[_nftId]=_buyer;
    }
}
