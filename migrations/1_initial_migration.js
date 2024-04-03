const Argumentation = artifacts.require('Argumentation');
const Negotiation = artifacts.require('Negotiation');
const Tinkering = artifacts.require('Tinkering');
const Balancing = artifacts.require('Balancing');

module.exports = function (deployer) {
  deployer.deploy(Argumentation);
  deployer.deploy(Negotiation);
  deployer.deploy(Tinkering);
  deployer.deploy(Balancing);
};
