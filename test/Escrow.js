const { expect } = require('chai');  // chai is an assertion library
const { ethers } = require('hardhat'); // ethers is js library to communicate with the smart contracts


// It converts currency to token
const tokens = (n) => {
    return ethers.utils.parseUnits(n.toString(), 'ether')
}
// tests in js can check all the behavior of the smart contract without checking everything by hand

// It describes the smart contract and we can just write the test example with it() func
// we are goin to deploy the real estate contract using ethers js
describe('Escrow', () => {

    let buyer, seller, inspector, lender
    let realEstate, escrow

    beforeEach(async ()=>{
        
        [buyer,seller,lender,inspector]=await ethers.getSigners();
        //signers are basically the fake people on the blockchain
        // console.log(signers)
        // console.log(realEstate.address)
        const RealEstate=await ethers.getContractFactory('RealEstate')  // This gets the compiled contract inside of hardhat 
        //Now we have to deploy it to the blockchain
         realEstate=await RealEstate.deploy();
        

         //mint an nft first
        //  while minting it takes a token uri as param 
        // minting from the sellers' perspective
        let transaction = await realEstate.connect(seller).mint("https://ipfs.io/ipfs/QmTudSYeM7mz3PkYEWXWqPjomRPHogcMFSq7XAvsvsgAPS")
        await transaction.wait()

        const Escrow=await ethers.getContractFactory('Escrow')

        escrow=await Escrow.deploy(realEstate.address,
            seller.address,
            inspector.address,
            lender.address
        )

         // Approve Property   // 1 is token id
         transaction = await realEstate.connect(seller).approve(escrow.address, 1)
         await transaction.wait()
 
         // List Property
         transaction = await escrow.connect(seller).list(1, buyer.address, tokens(10), tokens(5))
         await transaction.wait()
    })

    describe('Deployment',()=>{
        it('Returns NFT address',async ()=>{
            const result=await escrow.nftAddress();
            expect(result).to.be.equal(realEstate.address);
        })

        it('Returns seller',async ()=>{
            const result=await escrow.seller();
            expect(result).to.be.equal(seller.address);
        })

        it('Returns inspector',async ()=>{
            const result=await escrow.inspector();
            expect(result).to.be.equal(inspector.address);
        })

        it('Returns lender',async ()=>{
            const result=await escrow.lender();
            expect(result).to.be.equal(lender.address);
        })

    

    })

    describe('Listing',()=>{
        // check that the owner of the nft is the smart contract instead of the previous owner 
        it('Updates as listed', async () => {
            const result = await escrow.isListed(1)
            expect(result).to.be.equal(true)
        })

        it('Updates the ownership',async ()=>{
            // here ownerOf(1) means the first entity we created
            expect(await realEstate.ownerOf(1)).to.be.equal(escrow.address)
        })

        it('Returns buyer', async () => {
            const result = await escrow.buyer(1)
            expect(result).to.be.equal(buyer.address)
        })

        it('Returns purchase price', async () => {
            const result = await escrow.purchasePrice(1)
            expect(result).to.be.equal(tokens(10))
        })

        it('Returns escrow amount', async () => {
            const result = await escrow.escrowAmount(1)
            expect(result).to.be.equal(tokens(5))
        })

    })  

    describe('Deposits', () => {
        beforeEach(async () => {
            const transaction = await escrow.connect(buyer).depositEarnest(1, { value: tokens(5) })
            await transaction.wait()
        })

        it('Updates contract balance', async () => {
            const result = await escrow.getBalance()
            expect(result).to.be.equal(tokens(5))
        })
    })

    describe('Inspection', () => {
        beforeEach(async () => {
            const transaction = await escrow.connect(inspector).updateInspectionStatus(1, true)
            await transaction.wait()
        })

        it('Updates inspection status', async () => {
            const result = await escrow.inspectionPassed(1)
            expect(result).to.be.equal(true)
        })
    })

    describe('Approval', () => {
        beforeEach(async () => {
            let transaction = await escrow.connect(buyer).approveSale(1)
            await transaction.wait()

            transaction = await escrow.connect(seller).approveSale(1)
            await transaction.wait()

            transaction = await escrow.connect(lender).approveSale(1)
            await transaction.wait()
        })

        it('Updates approval status', async () => {
            expect(await escrow.approval(1, buyer.address)).to.be.equal(true)
            expect(await escrow.approval(1, seller.address)).to.be.equal(true)
            expect(await escrow.approval(1, lender.address)).to.be.equal(true)
        })
    })
    

    describe('Sale', () => {
        beforeEach(async () => {
            let transaction = await escrow.connect(buyer).depositEarnest(1, { value: tokens(5) })
            await transaction.wait()

            transaction = await escrow.connect(inspector).updateInspectionStatus(1, true)
            await transaction.wait()

            transaction = await escrow.connect(buyer).approveSale(1)
            await transaction.wait()

            transaction = await escrow.connect(seller).approveSale(1)
            await transaction.wait()

            transaction = await escrow.connect(lender).approveSale(1)
            await transaction.wait()

            await lender.sendTransaction({ to: escrow.address, value: tokens(5) })

            transaction = await escrow.connect(seller).finalizeSale(1)
            await transaction.wait()
        })

        it('Updates ownership', async () => {
            expect(await realEstate.ownerOf(1)).to.be.equal(buyer.address)
        })

        it('Updates balance', async () => {
            expect(await escrow.getBalance()).to.be.equal(0)
        })
    })
})
