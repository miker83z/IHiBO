const Argumentation = artifacts.require('Argumentation');
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

contract('Tinkering 0', (accounts) => {
  const alpha = accounts[0];
  const beta = accounts[1];
  const gamma = accounts[2];

  console.log(accounts);

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
/*
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
    const r3 = await sc.getGraph(2);
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
*/

/*
contract('Argumentation 2', (accounts) => {
  const alpha = accounts[0];
  const beta = accounts[1];
  const gamma = accounts[2];

  it('graph 3, new graph', async () => {
    const sc = await Argumentation.deployed();

    const resAlpha = await sc.insertArgument('a', {
      from: alpha,
    });
    const resAlphaGasUsed = resAlpha.receipt.gasUsed;
    const resGamma = await sc.insertArgument('b', {
      from: gamma,
    });
    const resGammaGasUsed = resGamma.receipt.gasUsed;
    const resBeta = await sc.insertArgument('c', {
      from: beta,
    });
    const resBetaGasUsed = resBeta.receipt.gasUsed;
    const resGamma2 = await sc.insertArgument('d', {
      from: gamma,
    });
    const resGamma2GasUsed = resGamma2.receipt.gasUsed;
    console.log(
      'insertArgument(): ',
      (resAlphaGasUsed + resBetaGasUsed + resGammaGasUsed + resGamma2GasUsed) /
        4
    );

    const resBetaSupport = await sc.supportArgument(1, {
      from: beta,
    });
    const resBetaSupportGasUsed = resBetaSupport.receipt.gasUsed;
    const resAlphaSupport = await sc.supportArgument(3, {
      from: alpha,
    });
    const resAlphaSupportGasUsed = resAlphaSupport.receipt.gasUsed;
    console.log(
      'supportArgument(): ',
      (resBetaSupportGasUsed + resAlphaSupportGasUsed) / 2
    );

    const edgeGasUsed = [];
    const edgeAB = await sc.insertAttack(1, 2, '');
    edgeGasUsed.push(edgeAB.receipt.gasUsed);
    const edgeAC = await sc.insertAttack(1, 3, '');
    edgeGasUsed.push(edgeAC.receipt.gasUsed);
    const edgeAD = await sc.insertAttack(1, 4, '');
    edgeGasUsed.push(edgeAD.receipt.gasUsed);

    const edgeBA = await sc.insertAttack(2, 1, '');
    edgeGasUsed.push(edgeBA.receipt.gasUsed);
    const edgeBC = await sc.insertAttack(2, 3, '');
    edgeGasUsed.push(edgeBC.receipt.gasUsed);
    const edgeBD = await sc.insertAttack(2, 4, '');
    edgeGasUsed.push(edgeBD.receipt.gasUsed);

    const edgeCA = await sc.insertAttack(3, 1, '');
    edgeGasUsed.push(edgeCA.receipt.gasUsed);
    const edgeCB = await sc.insertAttack(3, 2, '');
    edgeGasUsed.push(edgeCB.receipt.gasUsed);
    const edgeCD = await sc.insertAttack(3, 4, '');
    edgeGasUsed.push(edgeCD.receipt.gasUsed);

    const edgeDA = await sc.insertAttack(4, 1, '');
    edgeGasUsed.push(edgeDA.receipt.gasUsed);
    const edgeDB = await sc.insertAttack(4, 2, '');
    edgeGasUsed.push(edgeDB.receipt.gasUsed);
    const edgeDC = await sc.insertAttack(4, 3, '');
    edgeGasUsed.push(edgeDC.receipt.gasUsed);

    let avgGasUsed = 0;
    for (const gu of edgeGasUsed) {
      avgGasUsed += gu;
    }
    avgGasUsed /= edgeGasUsed.length;
    console.log('insertAttack(): ', avgGasUsed);

    const g = await sc.getGraph(1);
    printGraph(g);

    const resReduction3 = await sc.pafReductionToAfPr1();
    const r3 = await sc.getGraph(2);
    printGraph(r3);
    const resReduction3GasUsed = resReduction3.receipt.gasUsed;
    console.log('pafReductionToAfPr1(): ', resReduction3GasUsed);

    const r4 = await sc.enumeratingPreferredExtensions(2);
    r4.logs.forEach((element) => {
      console.log('*************************************');
      console.log(element.args.args);
    });
    const r4GasUsed = r4.receipt.gasUsed;
    console.log('enumeratingPreferredExtensions(): ', r4GasUsed);
  });
});
*/

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
