import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { network } from "hardhat";
import { decodeEventLog } from 'viem';
import { parseAbiItem } from 'viem';

import { createWalletClient, createPublicClient, http } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { anvil } from '@viem/anvil';
import fs from 'fs';
import { abi, address } from './Argumentation.sol'; // Replace with actual ABI and deployed address



const eventAbi = [
  {
    type: 'event',
    name: 'PreferredExtensions',
    inputs: [
      {
        name: 'args',
        type: 'uint256[]',
        indexed: false,
      },
    ],
  },
];

// Define a minimal Graph shape. You can refine it to your actual types.
export interface Graph<N = unknown> {
  nodes: N[];
  edgesSource: N[];
  edgesTarget: N[];
}

/**
 * Prints a graph to the console.
 * Uses String(x) instead of x.toString() so it works for any N (number, object, etc.)
 */
export function printGraph<N>(g: Graph<N>): void {
  console.log("--------Graph--------");

    // let nodes = g[0];
    // let edgesSource = g[1];
    // let edgesTarget = g[2];

  for (const node of g.nodes) {
    console.log("Node:", String(node));
  }

  const len = Math.min(g.edgesSource.length, g.edgesTarget.length);
  for (let i = 0; i < len; i++) {
    console.log(String(g.edgesSource[i]), " -> ", String(g.edgesTarget[i]));
  }
}

/**
 * Returns a random integer in the inclusive range [min, max].
 * Swaps if min > max to be robust.
 */
export function getRandomIntInclusive(min: number, max: number): number {
  let lo = Math.ceil(min);
  let hi = Math.floor(max);
  if (hi < lo) {
    const tmp = lo; lo = hi; hi = tmp;
  }
  return Math.floor(Math.random() * (hi - lo + 1)) + lo;
}


describe("Argumentation", async function () {
  const { viem } = await network.connect();
  const publicClient = await viem.getPublicClient();
  const [alpha, beta, gamma] = await viem.getWalletClients();

  it("IHiBO original graph test", async () => {
    const sc = await viem.deployContract("Argumentation");

    // Insert arguments
    await sc.write.insertArgument(["a"], { account: alpha.account });
    await sc.write.insertArgument(["b"], { account: beta.account });
    await sc.write.insertArgument(["c"], { account: gamma.account });

    // Support arguments
    await sc.write.supportArgument([3n], { account: beta.account });
    await sc.write.supportArgument([2n], { account: gamma.account });

    // Insert attacks
    await sc.write.insertAttack([1n, 2n, ""], { account: alpha.account });
    await sc.write.insertAttack([2n, 1n, ""], { account: beta.account });
    await sc.write.insertAttack([1n, 3n, ""], { account: alpha.account });
    await sc.write.insertAttack([3n, 1n, ""], { account: gamma.account });

    // Get original graph

    const gRaw = await sc.read.getGraph([1n]);
    const g: Graph<number> = {
      nodes: gRaw[0].map(n => Number(n)),
      edgesSource: gRaw[1].map(n => Number(n)),
      edgesTarget: gRaw[2].map(n => Number(n)),
    };
    printGraph(g);


    // Reduction 1
    await sc.write.pafReductionToAfPr1({ account: alpha.account });
    const r1Raw = await sc.read.getGraph([2n]);
    console.log("--------Reduction 1--------");
    const r1: Graph<number> = {
      nodes: r1Raw[0].map(n => Number(n)),
      edgesSource: r1Raw[1].map(n => Number(n)),
      edgesTarget: r1Raw[2].map(n => Number(n)),
    };
    printGraph(r1);

    // Reduction 3
    await sc.write.pafReductionToAfPr3({ account: alpha.account });
    const r3Raw = await sc.read.getGraph([3n]);
    console.log("--------Reduction 3--------");
    const r3: Graph<number> = {
      nodes: r3Raw[0].map(n => Number(n)),
      edgesSource: r3Raw[1].map(n => Number(n)),
      edgesTarget: r3Raw[2].map(n => Number(n)),
    };
    printGraph(r3);

    // Preferred extensions
    console.log("--------Preferred Extensions--------");
    const txHash = await sc.write.enumeratingPreferredExtensions([3n], { account: alpha.account });
    const receipt = await publicClient.getTransactionReceipt({ hash: txHash });
    console.log('Total logs:', receipt.logs.length);
    const eventAbi = parseAbiItem('event PreferredExtensions(uint256[] args)');
    const logs = receipt.logs.filter(log => log.address.toLowerCase() === sc.address.toLowerCase());
    logs.forEach((log) => {
      try {
        const decoded = decodeEventLog({
          abi: [eventAbi],
          data: log.data,
          topics: log.topics,
        });
        console.log('***************************************');
        console.log(decoded.args);
      } catch (err) {
        console.log('Log did not match PreferredExtensions event');
      }
    });
    console.log('***************************************');

    // Basic assertion
    assert.ok(g.nodes.length > 0, "Graph should have nodes");
    // console.log("Random int [1,10]:", getRandomIntInclusive(1, 10));
    
  });
});


describe('Argumentation 1', async (accounts) => {
  const { viem } = await network.connect();
  const publicClient = await viem.getPublicClient();
  const [alpha, beta, gamma] = await viem.getWalletClients();

  it('graph 2, related work', async () => {
    const sc = await viem.deployContract("Argumentation");

    const resAlpha = await sc.write.insertArgument(['b'], { account: alpha.account });
    // const resAlphaGasUsed = resAlpha.receipt.gasUsed;
    const resBeta = await sc.write.insertArgument(['c'], { account: beta.account });
    // const resBetaGasUsed = resBeta.receipt.gasUsed;
    const resGamma = await sc.write.insertArgument(['d'], { account: gamma.account });
    // const resGammaGasUsed = resGamma.receipt.gasUsed;
    const resAlpha2 = await sc.write.insertArgument(['e'], { account: alpha.account });
    // const resAlpha2GasUsed = resAlpha2.receipt.gasUsed;
    // console.log(
    //   'insertArgument(): ',
    //   (resAlphaGasUsed + resBetaGasUsed + resGammaGasUsed + resAlpha2GasUsed) /
    //     4
    // );

    const resBetaSupport = await sc.write.supportArgument([3n], {
      account: beta.account,
    });
    // const resBetaSupportGasUsed = resBetaSupport.receipt.gasUsed;
    const resGammaSupport = await sc.write.supportArgument([2n], {
      account: gamma.account,
    });
    // const resGammaSupportGasUsed = resGammaSupport.receipt.gasUsed;
    // console.log(
    //   'supportArgument(): ',
    //   (resBetaSupportGasUsed + resGammaSupportGasUsed) / 2
    // );

    // Insert attacks
    // originally they were not inserted by an address.
    const edgeBC = await sc.write.insertAttack([1n, 2n, ""], { account: alpha.account });
    // const edgeBCGasUsed = edgeBC.receipt.gasUsed;
    const edgeCD = await sc.write.insertAttack([2n, 3n, ""], { account: beta.account });
    // const edgeCDGasUsed = edgeCD.receipt.gasUsed;
    const edgeCE = await sc.write.insertAttack([2n, 4n, ""], { account: beta.account });
    // const edgeCEGasUsed = edgeCE.receipt.gasUsed;
    const edgeDB = await sc.write.insertAttack([3n, 1n, ""], { account: gamma.account });
    // const edgeDBGasUsed = edgeDB.receipt.gasUsed;
    const edgeED = await sc.write.insertAttack([4n, 3n, ""], { account: gamma.account });
    // const edgeEDGasUsed = edgeED.receipt.gasUsed;
    // console.log(
    //   'insertAttack(): ',
    //   (edgeBCGasUsed +
    //     edgeCDGasUsed +
    //     edgeCEGasUsed +
    //     edgeDBGasUsed +
    //     edgeEDGasUsed) /
    //     5
    // );

    console.log("--------Original Graph--------");
    const gRaw = await sc.read.getGraph([1n]);
    const g: Graph<number> = {
      nodes: gRaw[0].map(n => Number(n)),
      edgesSource: gRaw[1].map(n => Number(n)),
      edgesTarget: gRaw[2].map(n => Number(n)),
    };
    printGraph(g);

    const resReduction3 = await sc.write.pafReductionToAfPr3();
    console.log("--------Reduction 3--------");
    const r3Raw = await sc.read.getGraph([2n]);
    const r3: Graph<number> = {
      nodes: r3Raw[0].map(n => Number(n)),
      edgesSource: r3Raw[1].map(n => Number(n)),
      edgesTarget: r3Raw[2].map(n => Number(n)),
    };
    printGraph(r3);
    // const resReduction3GasUsed = resReduction3.receipt.gasUsed;
    // console.log('pafReductionToAfPr3(): ', resReduction3GasUsed);

    // const resReductionPref = await sc.write.enumeratingPreferredExtensions([2n]);
    // console.log("--------Preferred Extensions--------");
    // const r4Raw = await sc.read.getGraph([3n]); 
    // const r4: Graph<number> = {
    //   nodes: r4Raw[0].map(n => Number(n)),
    //   edgesSource: r4Raw[1].map(n => Number(n)),
    //   edgesTarget: r4Raw[2].map(n => Number(n)),
    // };
    // printGraph(r4);
    // r4.logs.forEach((element) => {
    //   console.log('*************************************');
    //   console.log(element.args.args);
    // });
    // const r4GasUsed = r4.receipt.gasUsed;
    // console.log('enumeratingPreferredExtensions(): ', r4GasUsed);

        // Preferred extensions
    console.log("--------Preferred Extensions--------");
    const txHash = await sc.write.enumeratingPreferredExtensions([2n], { account: alpha.account });
    const receipt = await publicClient.getTransactionReceipt({ hash: txHash });
    console.log('Total logs:', receipt.logs.length);
    const eventAbi = parseAbiItem('event PreferredExtensions(uint256[] args)');
    const logs = receipt.logs.filter(log => log.address.toLowerCase() === sc.address.toLowerCase());
    logs.forEach((log) => {
      try {
        const decoded = decodeEventLog({
          abi: [eventAbi],
          data: log.data,
          topics: log.topics,
        });
        console.log('***************************************');
        console.log(decoded.args);
      } catch (err) {
        console.log('Log did not match PreferredExtensions event');
      }
    });
    console.log('***************************************');



  });
});


describe('Argumentation 2', async (accounts) => {
  const { viem } = await network.connect();
  const publicClient = await viem.getPublicClient();
  const [alpha, beta, gamma] = await viem.getWalletClients();

  it('graph 3, new graph', async () => {
    const sc = await viem.deployContract("Argumentation");

    const resAlpha = await sc.write.insertArgument(['a'], { account: alpha.account });
    // const resAlphaGasUsed = resAlpha.receipt.gasUsed;
    const resGamma = await sc.write.insertArgument(['b'], { account: gamma.account });
    // const resGammaGasUsed = resGamma.receipt.gasUsed;
    const resBeta = await sc.write.insertArgument(['c'], { account: beta.account });
    // const resBetaGasUsed = resBeta.receipt.gasUsed;
    const resGamma2 = await sc.write.insertArgument(['d'], { account: gamma.account });
    // const resGamma2GasUsed = resGamma2.receipt.gasUsed;
    // console.log(
    //   'insertArgument(): ',
    //   (resAlphaGasUsed + resBetaGasUsed + resGammaGasUsed + resGamma2GasUsed) /
    //     4
    // );

    const resBetaSupport = await sc.write.supportArgument([1n], { account: beta.account });
    // const resBetaSupportGasUsed = resBetaSupport.receipt.gasUsed;
    const resAlphaSupport = await sc.write.supportArgument([3n], {
      account: alpha.account,
    });
    // const resAlphaSupportGasUsed = resAlphaSupport.receipt.gasUsed;
    // console.log(
    //   'supportArgument(): ',
    //   (resBetaSupportGasUsed + resAlphaSupportGasUsed) / 2
    // );

    const edgeGasUsed = [];
    const edgeAB = await sc.write.insertAttack([1n, 2n, '']);
    // edgeGasUsed.push(edgeAB.receipt.gasUsed);
    const edgeAC = await sc.write.insertAttack([1n, 3n, '']);
    // edgeGasUsed.push(edgeAC.receipt.gasUsed);
    const edgeAD = await sc.write.insertAttack([1n, 4n, '']);
    // edgeGasUsed.push(edgeAD.receipt.gasUsed);

    const edgeBA = await sc.write.insertAttack([2n, 1n, '']);
    // edgeGasUsed.push(edgeBA.receipt.gasUsed);
    const edgeBC = await sc.write.insertAttack([2n, 3n, '']);
    // edgeGasUsed.push(edgeBC.receipt.gasUsed);
    const edgeBD = await sc.write.insertAttack([2n, 4n, '']);
    // edgeGasUsed.push(edgeBD.receipt.gasUsed);

    const edgeCA = await sc.write.insertAttack([3n, 1n, '']);
    // edgeGasUsed.push(edgeCA.receipt.gasUsed);
    const edgeCB = await sc.write.insertAttack([3n, 2n, '']);
    // edgeGasUsed.push(edgeCB.receipt.gasUsed);
    const edgeCD = await sc.write.insertAttack([3n, 4n, '']);
    // edgeGasUsed.push(edgeCD.receipt.gasUsed);

    const edgeDA = await sc.write.insertAttack([4n, 1n, '']);
    // edgeGasUsed.push(edgeDA.receipt.gasUsed);
    const edgeDB = await sc.write.insertAttack([4n, 2n, '']);
    // edgeGasUsed.push(edgeDB.receipt.gasUsed);
    const edgeDC = await sc.write.insertAttack([4n, 3n, '']);
    // edgeGasUsed.push(edgeDC.receipt.gasUsed);

    // let avgGasUsed = 0;
    // for (const gu of edgeGasUsed) {
    //   avgGasUsed += gu;
    // }
    // avgGasUsed /= edgeGasUsed.length;
    // console.log('insertAttack(): ', avgGasUsed);

    console.log('--------Original Graph--------');
    const gRaw = await sc.read.getGraph([1n]);
    const g: Graph<number> = {
      nodes: gRaw[0].map(n => Number(n)),
      edgesSource: gRaw[1].map(n => Number(n)),
      edgesTarget: gRaw[2].map(n => Number(n)),
    };
    printGraph(g);

    const resReduction3 = await sc.write.pafReductionToAfPr1();
    console.log('--------Reduction 1--------');
    const r3Raw = await sc.read.getGraph([2n]);
    const r3: Graph<number> = {
      nodes: r3Raw[0].map(n => Number(n)),
      edgesSource: r3Raw[1].map(n => Number(n)),
      edgesTarget: r3Raw[2].map(n => Number(n)),
    };
    printGraph(r3);
    // const resReduction3GasUsed = resReduction3.receipt.gasUsed;
    // console.log('pafReductionToAfPr1(): ', resReduction3GasUsed);

    // const resReductionPref = await sc.write.enumeratingPreferredExtensions([2n]);
    // console.log('--------Preferred Extensions--------');
    // const r4Raw = await sc.read.getGraph([3n]); 
    // const r4: Graph<number> = {
    //   nodes: r4Raw[0].map(n => Number(n)),
    //   edgesSource: r4Raw[1].map(n => Number(n)),
    //   edgesTarget: r4Raw[2].map(n => Number(n)),
    // };
    // printGraph(r4);
    // r4.logs.forEach((element) => {
    //   console.log('*************************************');
    //   console.log(element.args.args);
    // });
    // const r4GasUsed = r4.receipt.gasUsed;
    // console.log('enumeratingPreferredExtensions(): ', r4GasUsed);

    // Preferred extensions
    console.log("--------Preferred Extensions--------");
    const txHash = await sc.write.enumeratingPreferredExtensions([3n], { account: alpha.account });
    const receipt = await publicClient.getTransactionReceipt({ hash: txHash });
    console.log('Total logs:', receipt.logs.length);
    const eventAbi = parseAbiItem('event PreferredExtensions(uint256[] args)');
    const logs = receipt.logs.filter(log => log.address.toLowerCase() === sc.address.toLowerCase());
    logs.forEach((log) => {
      try {
        const decoded = decodeEventLog({
          abi: [eventAbi],
          data: log.data,
          topics: log.topics,
        });
        console.log('***************************************');
        console.log(decoded.args);
      } catch (err) {
        console.log('Log did not match PreferredExtensions event');
      }
    });
    console.log('***************************************');

  });
});


// /*
const filepath = './data.csv';
for (let i = 0; i < 1; i++) {
  describe('Argumentation N', async (accounts) => {
    const { viem } = await network.connect();
    const publicClient = await viem.getPublicClient();
    const [alpha, beta, gamma] = await viem.getWalletClients();

    const prefP = 0.25;
    const nodesNumber = 5;
    const edgesP = 0.66;
    let edgesNumber = 0;

    it('graph 3, new graph', async () => {
      const sc = await viem.deployContract("Argumentation");

      for (let j = 0; j < nodesNumber; j++) {
        await sc.write.insertArgument(['a'], { 
          account: alpha.account 
        });
        // sc.insertArgument(`a`, {
        //   from: accounts[j % 3],
        // });
        for (let k = 1; k <= 2; k++) {
          if (Math.random() < prefP) {
            await sc.write.supportArgument([BigInt(j+1)], { 
              account: beta.account 
            });
            // sc.supportArgument(j + 1, {
            //   from: accounts[(j + k) % 3],
            // });
          }
        }
      }

      for (let source = 1; source <= nodesNumber; source++) {
        for (let target = 1; target <= nodesNumber; target++) {
          if (Math.random() < edgesP && source != target) {
            await sc.write.insertAttack([BigInt(source), BigInt(target), '']);
            edgesNumber++;
          }
        }
      }

      // const g = await sc.read.getGraph([1n]);
      // printGraph(g);
      // console.log('--------Original Graph--------');
      // const gRaw = await sc.read.getGraph([1n]);
      // const g: Graph<number> = {
      //   nodes: gRaw[0].map(n => Number(n)),
      //   edgesSource: gRaw[1].map(n => Number(n)),
      //   edgesTarget: gRaw[2].map(n => Number(n)),
      // };
      // printGraph(g);

      const resReduction3 = await sc.write.pafReductionToAfPr3();
      //const r3 = await sc.getGraph(3);
      //printGraph(r3);
      const reductionReceipt = await publicClient.getTransactionReceipt({ hash: resReduction3 });
      const reductionGasUsed = reductionReceipt?.gasUsed;
      console.log(reductionGasUsed);

      const txHash = await sc.write.enumeratingPreferredExtensions([2n], { account: alpha.account });
      const receipt = await publicClient.getTransactionReceipt({ hash: txHash });
      // If receipt is undefined, gasUsed will be undefined as well
      const gasUsed = receipt?.gasUsed;
      console.log(gasUsed);

      fs.writeFileSync(
        filepath,
        `${nodesNumber}, ${edgesNumber}, ${edgesP}, ${prefP}, ${reductionGasUsed}, ${gasUsed}\n`,
        { flag: 'a' }
      );
    });
  });
}
// */


/*
const nodesNumber = 5;
const prefP = 0.25;
const edgesP = 0.66;
let edgesNumber = 0;

const filepath = './results.csv';

async function runTest() {
  const client = createWalletClient({
    transport: http(),
    account: privateKeyToAccount('0x...'), // Replace with actual test key
  });

  const publicClient = createPublicClient({
    transport: http(),
  });

  const accounts = [client.account.address];

  // Insert arguments
  for (let j = 0; j < nodesNumber; j++) {
    await client.writeContract({
      address,
      abi,
      functionName: 'insertArgument',
      args: ['a'],
      account: accounts[j % 3],
    });

    for (let k = 1; k <= 2; k++) {
      if (Math.random() < prefP) {
        await client.writeContract({
          address,
          abi,
          functionName: 'supportArgument',
          args: [BigInt(j + 1)],
          account: accounts[(j + k) % 3],
        });
      }
    }
  }

  // Insert attacks
  for (let source = 1; source <= nodesNumber; source++) {
    for (let target = 1; target <= nodesNumber; target++) {
      if (Math.random() < edgesP && source !== target) {
        await client.writeContract({
          address,
          abi,
          functionName: 'insertAttack',
          args: [BigInt(source), BigInt(target), ''],
        });
        edgesNumber++;
      }
    }
  }

  // Reduction
  const reductionTx = await client.writeContract({
    address,
    abi,
    functionName: 'pafReductionToAfPr3',
  });
  const reductionReceipt = await publicClient.getTransactionReceipt({ hash: reductionTx });
  const reductionGasUsed = reductionReceipt?.gasUsed;

  // Enumeration
  const enumerationTx = await client.writeContract({
    address,
    abi,
    functionName: 'enumeratingPreferredExtensions',
    args: [BigInt(2)],
  });
  const enumerationReceipt = await publicClient.getTransactionReceipt({ hash: enumerationTx });
  const gasUsed = enumerationReceipt?.gasUsed;

  // Write results
  fs.writeFileSync(
    filepath,
    `${nodesNumber}, ${edgesNumber}, ${edgesP}, ${prefP}, ${reductionGasUsed}, ${gasUsed}\n`,
    { flag: 'a' }
  );

  console.log('Test completed.');
}

runTest().catch(console.error);
*/