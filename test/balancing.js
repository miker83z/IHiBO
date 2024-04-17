const Balancing = artifacts.require('Balancing');
const fs = require('fs');
const filepath = './data4.csv';
// import LogRocket from 'logrocket';

// LogRocket.init('2dxvqu/bullshit');


const printReasons = (R) => {
  console.log('--------Reasons--------');

  const V = ['?', '-', '+'];

  for (let i = 0; i < R.justifications.length; i++) {
    if (R.polarities[i] == 0 || R.polarities[i] == 1 || R.polarities[i] == 2 ) {
      let x = "x";
      let y = "y";
      let r = "r";
      R.justifications[i] == 0 ? x += "?" : x += R.justifications[i].toString();
      R.issues[i] == 0 ? y += "?" : y += R.issues[i].toString();
      i == 0 ? r += "?" : r += i.toString();

      console.log(
        r,
        ' =  (', x, ', ',  y, ', ',
        V[R.polarities[i]], ')'
      );
    } else {
      console.log("NaR: Not available Reason");
    }
  }
  console.log('-----------------------');
};

const printContexts = (C) => {
  console.log('--------Contexts--------');

  for (let i = 0; i < C.issues.length; i++) {
    let x = '';
    if (C.reasonss[i].length > 0) {
      C.reasonss[i][0] == 0 ? x = 'r?' : x = 'r' + C.reasonss[i][0].toString();
      for (let j = 1; j < C.reasonss[i].length; j++) {
        C.reasonss[i][j] == 0 ? x = x + ', r?' : x = x + ', r' + C.reasonss[i][j].toString();
      }
    } 
    else {
    }
    let y = 'y';
    let c = 'c';
    C.issues[i] == 0 ? y += '?' : y += C.issues[i].toString();
    i == 0 ? c += '?' : c += i.toString();
    console.log(
      c, ' = ( (', x, '), ', y, ')'
    );
  } 

  console.log('------------------------');
};

const printWeights = (W) => {
  console.log('--------Weights--------');
  // TODO after getWeights is finished
  for (let i = 0; i < W.length; i++) {
    for (let j = 0; j < W[i].length; j++) {
      let input = '(r' + j.toString() + ', c' + i.toString() + ')';
      console.log('f_{w?}(' + input + ') = ' + W[i][j]);
    }
  }

  console.log('------------------------');
};

const printValuation = (cases, p) => {
  console.log('--------valuations--------');

  const V = ['?', '-', '+'];

  assert(cases.length == p.length);
  for (let i = 0; i < p.length; i++) {
    assert(p[i]<3);
    const valuation = V[p[i]];
    console.log('c'+cases[i].toString(), ': ', valuation);    
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

    const resAlpha10 = await sc.insertReason.call(1,1,1, {
      from: alpha,
    });
    const resAlpha1 = await sc.insertReason(1,1,1, {
      from: alpha,
    });
    const resAlpha12 = await sc.insertReason.call(1,1,1, {
      from: alpha,
    });

    const resAlpha20 = await sc.insertReason.call(2,1,2, {
      from: alpha,
    });
    const resAlpha2 = await sc.insertReason(2,1,2, {
      from: alpha,
    });
    const resAlpha22 = await sc.insertReason.call(2,1,2, {
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

    const resAlpha4 = await sc.insertReason(4,1,0, {
      from: alpha,
    });

    // console.log(resAlpha10.toString(), resAlpha1.toString(), resAlpha12.toString());
    // console.log(resAlpha20.toString(), resAlpha2.toString(), resAlpha22.toString());
    // console.log(resAlpha30.toString(), resAlpha3.toString(), resAlpha31.toString());

    const reasons = await sc.getReasons();

    printReasons(reasons);

    const conAlpha1 = await sc.insertContext([1,2],1, {
      from: alpha,
    });

    // const conAlpha12 = await sc.insertContext.call([0,1],3, {
    //   from: alpha,
    // });

    const conAlpha2 = await sc.insertContext([35,36],42, {
      from: alpha,
    });
    
    const contexts = await sc.getContexts();

    printContexts(contexts);

    // sc.changeWeight(0,0,1,1);
    // const weight = await sc.returnWeight.call(0,0);
    // console.log(weight.toString());

    // const w20 = await sc.returnWeight.call(3,0);
    // console.log(w20.toString());

    await sc.changeWeight(0,1,1,3);
    // await sc.changeWeight(0,2,1,3);

    // const w21 = await sc.returnWeight.call(3,0);
    // console.log(w21.toString());

    const weights = await sc.getWeights.call(0);

    // console.log(weights.toString());

    printWeights(weights);


    const pa1 = await sc.procedureAdditive.call(0,[1,2]);

    console.log(pa1.toString());

    printValuation([1,2], pa1);

    
  

    // const pa1 = await sc.bla.call(0,1);

    // console.log(pa1.toString());

    // const pa1 = await sc.alb.call(0);

    // console.log(pa1.toString());
    

    // sc.Bla().watch({}, '', function(error, result)) {
    //   console.log(result);
    // }

    // console.log(Array.isArray(contexts.issues));

    // console.log('printing contexts array:');
    // contexts[1].forEach(function(entry) {
    //   console.log(entry.toString());
    // });

  });
});


