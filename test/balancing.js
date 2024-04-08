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
        "r" + i.toString(),
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
        "r" + i.toString(),
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

const printContexts = (C) => {
  console.log('--------Contexts--------');

  for (let i = 0; i < C.issues.length; i++) {
    let x = C.reasonss[i][0].toString();
    for (let j = 1; j < C.reasonss[i].length; j++) {
      x = x + ', ' + C.reasonss[i][j].toString();
    }
    console.log(
      "c" + i.toString(),
      ' = ( (',
      x,             
      '), ',
      C.issues[i].toString(),
      ')'
    );
  } 

  console.log('------------------------');
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

    const resAlpha10 = await sc.insertReason.call(1,1,0, {
      from: alpha,
    });
    const resAlpha1 = await sc.insertReason(1,1,0, {
      from: alpha,
    });
    const resAlpha12 = await sc.insertReason.call(1,1,0, {
      from: alpha,
    });

    const resAlpha20 = await sc.insertReason.call(2,1,0, {
      from: alpha,
    });
    const resAlpha2 = await sc.insertReason(2,1,0, {
      from: alpha,
    });
    const resAlpha22 = await sc.insertReason.call(2,1,0, {
      from: alpha,
    });

    const resAlpha30 = await sc.insertReason.call(3,1,0, {
      from: alpha,
    });
    const resAlpha3 = await sc.insertReason(3,1,0, {
      from: alpha,
    });
    const resAlpha31 = await sc.insertReason.call(3,1,0, {
      from: alpha,
    });

    console.log(resAlpha10.toString(), resAlpha1.toString(), resAlpha12.toString());
    console.log(resAlpha20.toString(), resAlpha2.toString(), resAlpha22.toString());
    console.log(resAlpha30.toString(), resAlpha3.toString(), resAlpha31.toString());

    const reasons = await sc.getReasons();

    printReasons(reasons);

    
    const conAlpha1 = await sc.insertContext([0,1],3, {
      from: alpha,
    });

    const conAlpha12 = await sc.insertContext.call([0,1],3, {
      from: alpha,
    });

    const conAlpha2 = await sc.insertContext([35,36],42, {
      from: alpha,
    });

    
    const contexts = await sc.getContexts();

    printContexts(contexts);

    // console.log(Array.isArray(contexts.issues));

    // console.log('printing contexts array:');
    // contexts[1].forEach(function(entry) {
    //   console.log(entry.toString());
    // });

  });
});


