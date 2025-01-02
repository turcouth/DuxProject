const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Configuration de Test", function() {
    it("Devrait pouvoir accéder à ethers et aux comptes", async function() {
        const [owner] = await ethers.getSigners();
        expect(owner.address).to.match(/^0x[0-9a-fA-F]{40}$/);
    });
}); 