const Argumentation = artifacts.require('Argumentation');
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
    /*r4.logs.forEach((element) => {
      console.log('***************************************');
      console.log(element.args.args);
    });*/
/*  });
});

contract('Argumentation 1', (accounts) => {
  const alpha = accounts[0];
  const beta = accounts[1];
  const gamma = accounts[2];

  it('graph 2, related work', async () => {
    const sc = await Argumentation.deployed();

    const resAlpha = await sc.insertArgument('b', {
      from: alpha,
    });
    const resBeta = await sc.insertArgument('c', {
      from: beta,
    });
    const resGamma = await sc.insertArgument('d', {
      from: gamma,
    });
    const resAlpha2 = await sc.insertArgument('e', {
      from: alpha,
    });
    const resBetaSupport = await sc.supportArgument(3, {
      from: beta,
    });
    const resGammaSupport = await sc.supportArgument(2, {
      from: gamma,
    });

    const edgeBC = await sc.insertAttack(1, 2, '');
    const edgeCD = await sc.insertAttack(2, 3, '');
    const edgeCE = await sc.insertAttack(2, 4, '');
    const edgeDB = await sc.insertAttack(3, 1, '');
    const edgeED = await sc.insertAttack(4, 3, '');

    const g = await sc.getGraph(1);
    //printGraph(g);

    const r4 = await sc.enumeratingPreferredExtensions(1);
    /* r4.logs.forEach((element) => {
      console.log('*************************************');
      console.log(element.args.args);
    });*/
/*  });
});
*/
for (let i = 0; i < 1; i++) {
  contract('Argumentation N', (accounts) => {
    const alpha = accounts[0];
    const beta = accounts[1];
    const gamma = accounts[2];
    const nodesNumber = 10;
    const edgesNumber = 2 * nodesNumber;

    it('random graphs', async () => {
      const sc = await Argumentation.deployed();

      for (let j = 0; j < nodesNumber; j++) {
        await sc.insertArgument(`a`, {
          from: accounts[j % 3],
        });
      }

      const edges = Array(nodesNumber)
        .fill()
        .map(() => Array(nodesNumber).fill(false));

      for (let j = 0; j < edgesNumber; j++) {
        let source = 0;
        let target = 0;
        do {
          do {
            source = getRandomIntInclusive(1, nodesNumber);
            target = getRandomIntInclusive(1, nodesNumber);
          } while (target === source);
        } while (edges[source - 1][target - 1]);
        edges[source - 1][target - 1] = true;
        await sc.insertAttack(source, target, '');
      }

      //const g = await sc.getGraph(1);
      //printGraph(g);

      const r4 = await sc.enumeratingPreferredExtensions(1);
      r4.logs.forEach((element) => {
        console.log('*************************************');
        console.log(element.args.args);
      });
      console.log(r4.receipt.gasUsed);
    });
  });
}

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
