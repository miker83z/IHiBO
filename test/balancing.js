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



// /*
contract('Balancing 1', (accounts) => {
  const alpha = accounts[0];
  // const beta = accounts[1];
  // const gamma = accounts[2];
  // const delta = accounts[3];

  it('Test 1', async () => {
    // Connect with Tinkering Contract
    const sc = await Tinkering.deployed();




    
  });
});
/



/*
fs.writeFile(filepath, `NodesNumber, EdgesNumber, EdgesP, PrefP, ReductionPref3, PrefExtensionsGas\n`, (err) => {
  if (err) throw err;
  console.log('New data file has been saved!');
});

for (let i = 0; i < 2; i++) {

  console.log('checkpoint: 1');

  contract('Tinkering N:' + i, (accounts) => {
    const alpha = accounts[0];
    const beta = accounts[1];
    const gamma = accounts[2];
    const prefP = 0.25;
    const nodesNumber = [2,3,2,3];
    const edgesP = [0.33,0.5,0.66];
    let edgesNumber = 0;

    console.log('checkpoint: 2');

    it('random graphs', async () => {

      console.log(i, nodesNumber[i%4], edgesP[i%3]);

      console.log('checkpoint: 3');

      const sc = await Tinkering.deployed();

      console.log('checkpoint: 4');

      if (i>=1) {
        const k = await sc.getGraph2(1);
        printGraph2(k);
      }

      console.log('checkpoint: 5');
      
      for (let j = 0; j < nodesNumber[i%4]; j++) {
        console.log('insert node!');
        await sc.insertArgument(`a`, {
          from: accounts[j % 3],
        });
        console.log('bla');
        for (let k = 1; k <= 2; k++) {
          console.log('support node?');
          if (Math.random() < prefP) {
            console.log('support node!');
            await sc.supportArgument(j + 1, {
              from: accounts[(j + k) % 3],
            });
          }
        }
        console.log('blabla');
      }

      console.log('checkpoint: 6');

      for (let source = 1; source <= nodesNumber[i%4]; source++) {
        console.log('bla');
        for (let target = 1; target <= nodesNumber[i%4]; target++) {
          console.log('insert edge?');
          if (Math.random() < edgesP[i%3] && source != target) {
            console.log('insert edge!');
            await sc.insertAttack(source, target, '');
            edgesNumber++;
          }
        }
        console.log('blabla');
      }

      console.log('checkpoint: 7');

      const g = await sc.getGraph2(1);
      printGraph2(g);

      console.log('reduction');
      const resReduction3 = await sc.pafReductionToAfPr3();
      //const r3 = await sc.getGraph(3);
      //printGraph(r3);
      const reductionGasUsed = resReduction3.receipt.gasUsed;
      console.log(reductionGasUsed);

      console.log('extension');
      const r4 = await sc.enumeratingPreferredExtensions(2);
      //r4.logs.forEach((element) => {
      //  console.log('*************************************');
      //  console.log(element.args.args);
      //});
      const gasUsed = r4.receipt.gasUsed;
      console.log(gasUsed);

      fs.writeFileSync(
        filepath,
        `${nodesNumber[i%4]}, ${edgesNumber}, ${edgesP[i%3]}, ${prefP}, ${reductionGasUsed}, ${gasUsed}\n`,
        { flag: 'a' }
      );

      console.log('checkpoint: 8');
    });
    console.log('checkpoint: 9');
  });
  console.log('checkpoint: 10');
};
*/
