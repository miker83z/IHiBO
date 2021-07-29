const Argumentation = artifacts.require('Argumentation');
const Negotiation = artifacts.require('Negotiation');
const fs = require('fs');
const filepath = './data.csv';

const printGraph = (g) => {
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
};

const getRandomIntInclusive = (min, max) => {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min + 1) + min); //The maximum is inclusive and the minimum is inclusive
};
/*
contract('Argumentation 0', (accounts) => {
  const alpha = accounts[0];
  const beta = accounts[1];
  const gamma = accounts[2];

  it('graph 1, IHiBO original', async () => {
    const sc = await Argumentation.deployed();

    const resAlpha = await sc.insertArgument('a', {
      from: alpha,
    });
    const resBeta = await sc.insertArgument('b', {
      from: beta,
    });
    const resGamma = await sc.insertArgument('c', {
      from: gamma,
    });
    const resBetaSupport = await sc.supportArgument(3, {
      from: beta,
    });
    const resGammaSupport = await sc.supportArgument(2, {
      from: gamma,
    });

    const edgeAB = await sc.insertAttack(1, 2, '');
    const edgeBA = await sc.insertAttack(2, 1, '');
    const edgeAC = await sc.insertAttack(1, 3, '');
    const edgeCA = await sc.insertAttack(3, 1, '');

    const g = await sc.getGraph(1);
    //printGraph(g);

    const resReduction1 = await sc.pafReductionToAfPr1();
    //const r1 = await sc.getGraph(2);
    //printGraph(r1);

    const resReduction3 = await sc.pafReductionToAfPr3();
    //const r3 = await sc.getGraph(3);
    //printGraph(r3);

    const r4 = await sc.enumeratingPreferredExtensions(3);
    //r4.logs.forEach((element) => {
    //  console.log('***************************************');
    //  console.log(element.args.args);
    //});
  });
});
*/

contract('Argumentation 1', (accounts) => {
  const alpha = accounts[0];
  const beta = accounts[1];
  const gamma = accounts[2];

  it('graph 2, related work', async () => {
    const sc = await Argumentation.deployed();

    const resAlpha = await sc.insertArgument('b', {
      from: alpha,
    });
    const resAlphaGasUsed = resAlpha.receipt.gasUsed;
    const resBeta = await sc.insertArgument('c', {
      from: beta,
    });
    const resBetaGasUsed = resBeta.receipt.gasUsed;
    const resGamma = await sc.insertArgument('d', {
      from: gamma,
    });
    const resGammaGasUsed = resGamma.receipt.gasUsed;
    const resAlpha2 = await sc.insertArgument('e', {
      from: alpha,
    });
    const resAlpha2GasUsed = resAlpha2.receipt.gasUsed;
    console.log(
      'insertArgument(): ',
      (resAlphaGasUsed + resBetaGasUsed + resGammaGasUsed + resAlpha2GasUsed) /
        4
    );

    const resBetaSupport = await sc.supportArgument(3, {
      from: beta,
    });
    const resBetaSupportGasUsed = resBetaSupport.receipt.gasUsed;
    const resGammaSupport = await sc.supportArgument(2, {
      from: gamma,
    });
    const resGammaSupportGasUsed = resGammaSupport.receipt.gasUsed;
    console.log(
      'supportArgument(): ',
      (resBetaSupportGasUsed + resGammaSupportGasUsed) / 2
    );

    const edgeBC = await sc.insertAttack(1, 2, '');
    const edgeBCGasUsed = edgeBC.receipt.gasUsed;
    const edgeCD = await sc.insertAttack(2, 3, '');
    const edgeCDGasUsed = edgeCD.receipt.gasUsed;
    const edgeCE = await sc.insertAttack(2, 4, '');
    const edgeCEGasUsed = edgeCE.receipt.gasUsed;
    const edgeDB = await sc.insertAttack(3, 1, '');
    const edgeDBGasUsed = edgeDB.receipt.gasUsed;
    const edgeED = await sc.insertAttack(4, 3, '');
    const edgeEDGasUsed = edgeED.receipt.gasUsed;
    console.log(
      'insertAttack(): ',
      (edgeBCGasUsed +
        edgeCDGasUsed +
        edgeCEGasUsed +
        edgeDBGasUsed +
        edgeEDGasUsed) /
        5
    );

    const g = await sc.getGraph(1);
    printGraph(g);

    const resReduction3 = await sc.pafReductionToAfPr3();
    const r3 = await sc.getGraph(3);
    printGraph(r3);
    const resReduction3GasUsed = resReduction3.receipt.gasUsed;
    console.log('pafReductionToAfPr3(): ', resReduction3GasUsed);

    const r4 = await sc.enumeratingPreferredExtensions(2);
    r4.logs.forEach((element) => {
      console.log('*************************************');
      console.log(element.args.args);
    });
    const r4GasUsed = r4.receipt.gasUsed;
    console.log('enumeratingPreferredExtensions(): ', r4GasUsed);
  });
});

/*
for (let i = 0; i < 1; i++) {
  contract('Argumentation N', (accounts) => {
    const alpha = accounts[0];
    const beta = accounts[1];
    const gamma = accounts[2];
    const prefP = 0.25;
    const nodesNumber = 5;
    const edgesP = 0.66;
    let edgesNumber = 0;

    it('random graphs', async () => {
      const sc = await Argumentation.deployed();

      for (let j = 0; j < nodesNumber; j++) {
        await sc.insertArgument(`a`, {
          from: accounts[j % 3],
        });
        for (let k = 1; k <= 2; k++) {
          if (Math.random() < prefP) {
            await sc.supportArgument(j + 1, {
              from: accounts[(j + k) % 3],
            });
          }
        }
      }

      for (let source = 1; source <= nodesNumber; source++) {
        for (let target = 1; target <= nodesNumber; target++) {
          if (Math.random() < edgesP && source != target) {
            await sc.insertAttack(source, target, '');
            edgesNumber++;
          }
        }
      }

      //const g = await sc.getGraph(1);
      //printGraph(g);

      const resReduction3 = await sc.pafReductionToAfPr3();
      //const r3 = await sc.getGraph(3);
      //printGraph(r3);
      const reductionGasUsed = resReduction3.receipt.gasUsed;
      console.log(reductionGasUsed);

      const r4 = await sc.enumeratingPreferredExtensions(2);
      //r4.logs.forEach((element) => {
      //  console.log('*************************************');
      //  console.log(element.args.args);
      //});
      const gasUsed = r4.receipt.gasUsed;
      console.log(gasUsed);

      fs.writeFileSync(
        filepath,
        `${nodesNumber}, ${edgesNumber}, ${edgesP}, ${prefP}, ${reductionGasUsed}, ${gasUsed}\n`,
        { flag: 'a' }
      );
    });
  });
}
*/

////////////////////////////// NEGOTIATION

const scoringFunction = (x, constj) => {
  if (constj.Vjdec) {
    if (x > constj.maxj) return 0;
    else if (x < constj.minj) return 1;
    else return 1 - x / constj.maxj;
  } else {
    if (x > constj.maxj) return 1;
    else if (x < constj.minj) return 0;
    else return x / constj.maxj;
  }
};

const timeDependentTactic = (alphaj, constj) => {
  return constj.Vjdec
    ? constj.minj + alphaj * (constj.maxj - constj.minj)
    : constj.minj + (1 - alphaj) * (constj.maxj - constj.minj);
};

const negotiationPoly = (t, constj) => {
  return (
    constj.kj +
    (1 - constj.kj) *
      Math.pow(Math.min(t, constj.tmax) / constj.tmax, 1 / constj.beta)
  );
};

const interpretation = (t, xba, constj) => {
  if (t > constj.tmax) {
    return false;
  } else {
    const alphaj = negotiationPoly(t, constj);
    const xab = timeDependentTactic(alphaj, constj);
    if (scoringFunction(xba, constj) >= scoringFunction(xab, constj)) {
      return true;
    } else {
      return xab;
    }
  }
};

contract('Negotiation', (accounts) => {
  const alpha = accounts[0];
  const beta = accounts[1];

  it('negotiation 1', async () => {
    const sc = await Negotiation.deployed();
    const tmax = 20;
    const constjAlpha = {
      tmax,
      minj: 0,
      maxj: 20,
      kj: 0.1,
      beta: 1.5,
      Vjdec: true,
    };
    const constjBeta = {
      tmax,
      minj: 17,
      maxj: 35,
      kj: 0.1,
      beta: 10.2,
      Vjdec: false,
    };
    const res1 = await sc.newNegotiation(1, alpha, beta, {
      from: alpha,
    });
    console.log('newNegotiation(): ', res1.receipt.gasUsed);

    // negotiation thread
    const proposalsGasUsage = [];
    let xba = timeDependentTactic(negotiationPoly(0, constjBeta), constjBeta);
    const res2 = await sc.newProposal(0, Math.floor(xba * 10000), {
      from: beta,
    });
    proposalsGasUsage.push(res2.receipt.gasUsed);
    let xab;
    for (let t = 1; t <= tmax + 1; t++) {
      if (t % 2) {
        const res = interpretation(t, xba, constjAlpha);
        console.log(t, ') - a - ', res);
        if (typeof res === 'boolean') {
          if (res) {
            const resFinalA = await sc.accept(0, Math.floor(xba * 10000), {
              from: alpha,
            });
            console.log('accept(): ', resFinalA.receipt.gasUsed);
          }
          break;
        } else xab = res;
        const res3 = await sc.newProposal(0, Math.floor(xab * 10000), {
          from: alpha,
        });
        proposalsGasUsage.push(res3.receipt.gasUsed);
      } else {
        const res = interpretation(t, xab, constjBeta);
        console.log(t, ') - b - ', res);
        if (typeof res === 'boolean') {
          if (res) {
            const resFinalB = await sc.accept(0, Math.floor(xab * 10000), {
              from: beta,
            });
            console.log('accept(): ', resFinalB.receipt.gasUsed);
          }
          break;
        } else xba = res;
        const res4 = await sc.newProposal(0, Math.floor(xba * 10000), {
          from: beta,
        });
        proposalsGasUsage.push(res4.receipt.gasUsed);
      }
    }
    let gasAvgProp = 0;
    for (const propG of proposalsGasUsage) {
      gasAvgProp += propG;
    }
    console.log('newProposal(): ', gasAvgProp / proposalsGasUsage.length);
  });
});
