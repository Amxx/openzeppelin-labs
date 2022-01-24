const {
  shouldBehaveLikeERC721,
  // shouldBehaveLikeERC721Metadata,
} = require('./ERC721.behavior');

const OZMock     = artifacts.require('OZMock');
const OZEnumMock = artifacts.require('OZEnumMock');
const AzukiMock  = artifacts.require('AzukiMock');

contract('ERC721', function (accounts) {
  describe('OZ', function () {
    beforeEach(async function () {
      this.token = await OZMock.new();
    });

    shouldBehaveLikeERC721('ERC721', ...accounts);
    // shouldBehaveLikeERC721Metadata('ERC721', 'OZ', 'OZ', ...accounts);
  });

  describe('OZEnum', function () {
    beforeEach(async function () {
      this.token = await OZEnumMock.new();
    });

    shouldBehaveLikeERC721('ERC721', ...accounts);
    // shouldBehaveLikeERC721Metadata('ERC721', 'OZ', 'OZ', ...accounts);
  });

  describe('AzukiMock', function () {
    beforeEach(async function () {
      this.token = await AzukiMock.new();
    });

    shouldBehaveLikeERC721('ERC721', ...accounts);
    // shouldBehaveLikeERC721Metadata('ERC721', 'OZ', 'OZ', ...accounts);
  });

});
