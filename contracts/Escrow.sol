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



    modifier onlyBuyer(uint256 _nftId){
        require(msg.sender == buyer[_nftId], "Only buyer can modift this");
        _;
    } //P
    modifier onlySeller(){
        require(msg.sender == seller, "Only seller can call this method");
        _;
    }  //P
 modifier onlyInspector(){
        require(msg.sender == inspector, "Only inspector can call this method");
        _;
    }  //P



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
        //put under contract (only buyer- payable escrow)   //P
         function depositEarnest(uint256 _nftId) public payable onlyBuyer(_nftId){
            require(msg.value >= escrowAmount[_nftId]);

    }


    function updateInspectionStatus(uint256 _nftID, bool _passed)
        public
        onlyInspector
    {
        inspectionPassed[_nftID] = _passed;
    }



     // Approve Sale
    function approveSale(uint256 _nftID) public {
        approval[_nftID][msg.sender] = true;
    }


    // Finalize Sale
    // -> Require inspection status (add more items here, like appraisal)
    // -> Require sale to be authorized
    // -> Require funds to be correct amount
    // -> Transfer NFT to buyer
    // -> Transfer Funds to Seller
    function finalizeSale(uint256 _nftID) public {
        require(inspectionPassed[_nftID]);
        require(approval[_nftID][buyer[_nftID]]);
        require(approval[_nftID][seller]);
        require(approval[_nftID][lender]);
        require(address(this).balance >= purchasePrice[_nftID]);

        isListed[_nftID] = false;

        (bool success, ) = payable(seller).call{value: address(this).balance}(
            ""
        );
        require(success);

        IERC721(nftAddress).transferFrom(address(this), buyer[_nftID], _nftID);
    }
    
     // Cancel Sale (handle earnest deposit)
    // -> if inspection status is not approved, then refund, otherwise send to seller
    function cancelSale(uint256 _nftID) public {
        if (inspectionPassed[_nftID] == false) {
            payable(buyer[_nftID]).transfer(address(this).balance);
        } else {
            payable(seller).transfer(address(this).balance);
        }
    }

    receive() external payable{}  //P

    function getBalance() public view returns (uint256){  //P
        return address(this).balance;
    }
}
