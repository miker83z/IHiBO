const Argumentation = artifacts.require('Argumentation');
const Negotiation = artifacts.require('Negotiation');

module.exports = function (deployer) {
  deployer.deploy(Argumentation);
  deployer.deploy(Negotiation);
};
