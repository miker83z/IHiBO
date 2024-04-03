const Balancing = artifacts.require('Balancing');
const fs = require('fs');
const filepath = './data4.csv';
// import LogRocket from 'logrocket';

// LogRocket.init('2dxvqu/bullshit');

const printStuff = (g) => {
  console.log('--------Graph--------');
  for (const node of g.nodes) {
    console.log('Node:', node.toString());
  }

  for (let i = 0; i < g.edgesSource.length; i++) {
    console.log(
      g.edgesSource[i].toString(),
      ' -> ',
      g.edgesTarget[i].toString()
    );
  }
  console.log('---------------------');
};

const printReasons = (R) => {
  console.log('--------Reasons--------');

  const V = ['+', '-', '0'];

  for (let i = 0; i < R.justifications.length; i++) {
    if (R.polarities[i] == 0 || R.polarities[i] == 1 || R.polarities[i] == 2 ) {
      console.log(
        i,
        ' =  (',
        R.justifications[i].toString(),
        ', ',
        R.issues[i].toString(),
        ', ',
        V[R.polarities[i]],
        ')'
      );
    } else {
      console.log(
        i,
        ' =  (',
        R.justifications[i].toString(),
        ', ',
        R.issues[i].toString(),
        ', ',
        '?',
        ')'
      );
    }
  }
  console.log('-----------------------');
};


// /*
contract('Balancing 1', (accounts) => {
  const alpha = accounts[0];
  // const beta = accounts[1];
  // const gamma = accounts[2];
  // const delta = accounts[3];

  it('Test 1', async () => {
    // Connect with Balancing Contract
    const sc = await Balancing.deployed();

    const resAlpha1 = await sc.insertReason(1,1,0, {
      from: alpha,
    });
    

    const reasons = await sc.getReasons();

    printReasons(reasons);

    // Context context;
    // context.issue = 1;

    // Reason r1 = (1,1,1);
    // Reason r2 = (2,1,-1);
    // context.reasons[1] = r1;
    // context.reasons[2] = r2;
    

  });
});


