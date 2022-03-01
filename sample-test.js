const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe("POCP ROLES:", function () {
  let pocprole, pocp,owner;
  let add1, add2, add3, add4, add5, add6;
  const PAUSER_ROLE = "0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a";
  const UPGRADER_ROLE = "0x189ab7a9244df0848122154315af71fe140f3db0fe014031783b0946b8c9d2e3";
  beforeEach(async () =>{
    pocprole = await ethers.getContractFactory("POCPRoles");
    pocp = await pocprole.deploy();
    await pocp.deployed();
    [owner,add1, add2, add3, add4, add5,add6] = await ethers.getSigners();
    await pocp.initialize();
  });
  it("Should deploy and initilize the pocp roles", async function () {
    console.log("Contract Initilized!");
    console.log("Deploy addres of pocp roles is:", pocp.address);
  });

  it("should  check for Pausable and upgradable roles:", async() =>{
    console.log("Owner address is :",owner.address);
    expect(await pocp.hasRole(PAUSER_ROLE,owner.address)).to.equal(true);
    expect(await pocp.hasRole(UPGRADER_ROLE, owner.address)).to.equal(true);
    console.log("Check for different address");
    assert.notEqual(await pocp.hasRole(PAUSER_ROLE, add1.address), true);
    assert.notEqual(await pocp.hasRole(UPGRADER_ROLE, add1.address), true);
  });
  it("should  check for Pausable and upgradable roles:", async() =>{
    console.log("Owner address is :",owner.address);
    expect(await pocp.hasRole(PAUSER_ROLE,owner.address)).to.equal(true);
    expect(await pocp.hasRole(UPGRADER_ROLE, owner.address)).to.equal(true);
    console.log("Check for different address");
    assert.notEqual(await pocp.hasRole(PAUSER_ROLE, add1.address), true);
    assert.notEqual(await pocp.hasRole(UPGRADER_ROLE, add1.address), true);

    console.log("Granting the role to add1");

    await pocp.grantRole(PAUSER_ROLE, add1.address);
    assert.equal(await pocp.hasRole(PAUSER_ROLE, add1.address), true);
    console.log("Success address 1 has PAUSER_ROLE");
    console.log("Initial admin role of pauser_role is itself pauser_role", await pocp.getRoleAdmin(PAUSER_ROLE));

    console.log("Check for add1 to its role");
    assert.equal(await pocp.hasRole(PAUSER_ROLE, add1.address), true);
    console.log("Should revoke his role:");

    await pocp.connect(add1).renounceRole(PAUSER_ROLE, add1.address);

    assert.notEqual(await pocp.hasRole(PAUSER_ROLE, add1.address), true);

    console.log("Should revoked himself!");

    console.log("Get admin of all departments");

    console.log("Pausable ",await pocp.getRoleAdmin(PAUSER_ROLE));
    console.log("Upgradable ",await pocp.getRoleAdmin(UPGRADER_ROLE));

    console.log("check role for address 2");
    assert.equal(await pocp.hasRole(PAUSER_ROLE, add2.address), false);
    console.log("Granting role to address 2");

    await pocp.grantRole(PAUSER_ROLE, add2.address);

    console.log("Now, check role for address 2 again");
    assert.equal(await pocp.hasRole(PAUSER_ROLE, add2.address), true);

    console.log("Success!");

    console.log("revokeRole");

    await pocp.revokeRole(PAUSER_ROLE, add2.address);

    assert.equal(await pocp.hasRole(PAUSER_ROLE, add2.address), false);
  });
});
