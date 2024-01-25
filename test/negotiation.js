const Negotiation = artifacts.require('Negotiation');
const fs = require('fs');
const filepath2 = './data2.csv';

const negotiationPoly = (t, tmax, beta, constj) => {
  return (
    constj.kj + (1 - constj.kj) * Math.pow(Math.min(t, tmax) / tmax, 1 / beta)
  );
};

const timeDependentTactic = (t, tmax, beta, constj) => {
  const alphaj = negotiationPoly(t, tmax, beta, constj);
  return constj.Vjdec
    ? constj.minj + alphaj * (constj.maxj - constj.minj)
    : constj.minj + (1 - alphaj) * (constj.maxj - constj.minj);
};

const scoringFunction = (xj, constj) => {
  const v = (xj - constj.minj) / (constj.maxj - constj.minj);
  return constj.Vjdec ? 1 - v : v;
};

const multiDimensionalScoringFunction = (x, constAll) => {
  let finalValue = 0;
  for (let j = 0; j < constAll.constj.length; j++) {
    finalValue +=
      constAll.constj[j].weight * scoringFunction(x[j], constAll.constj[j]);
  }
  return finalValue;
};

const interpretation = (t, xba, constAll) => {
  if (t > constAll.tmax) {
    return false;
  } else {
    const xab = [];
    for (let j = 0; j < xba.length; j++) {
      xab.push(
        timeDependentTactic(t, constAll.tmax, constAll.beta, constAll.constj[j])
      );
    }
    if (
      multiDimensionalScoringFunction(xba, constAll) >=
      multiDimensionalScoringFunction(xab, constAll)
    ) {
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
    const tmax = 100;
    const constjAlpha = {
      tmax,
      beta: 0.9,
      constj: [
        {
          namej: 'price',
          weight: 0.4,
          minj: 146,
          maxj: 155,
          kj: 0.1,
          Vjdec: false,
        },
        {
          namej: 'quantity',
          weight: 0.6,
          minj: 1050,
          maxj: 1190,
          kj: 0.2,
          Vjdec: true,
        },
      ],
    };
    const constjBeta = {
      tmax,
      beta: 1.2,
      constj: [
        {
          namej: 'price',
          weight: 0.45,
          minj: 140,
          maxj: 149,
          kj: 0.1,
          Vjdec: true,
        },
        {
          namej: 'quantity',
          weight: 0.55,
          minj: 1100,
          maxj: 1250,
          kj: 0.2,
          Vjdec: false,
        },
      ],
    };
    const res1 = await sc.newNegotiation(beta, {
      from: alpha,
    });
    console.log('newNegotiation(): ', res1.receipt.gasUsed);

    // negotiation thread
    const proposalsGasUsage = [];

    let xba = [];
    for (let j = 0; j < constjBeta.constj.length; j++) {
      xba.push(
        timeDependentTactic(
          0,
          constjBeta.tmax,
          constjBeta.beta,
          constjBeta.constj[j]
        )
      );
    }
    const res2 = await sc.newOffer(
      0,
      xba.map((x) => Math.floor(x * 10000)),
      {
        from: beta,
      }
    );
    proposalsGasUsage.push(res2.receipt.gasUsed);
    let xab = [];
    for (let t = 1; t <= tmax + 1; t++) {
      if (t % 2) {
        console.log('a)');
        const res = interpretation(t, xba, constjAlpha);
        console.log(t, ') - a - ', res);
        if (typeof res === 'boolean') {
          if (res) {
            const resFinalA = await sc.accept(0, {
              from: alpha,
            });
            console.log('accept(): ', resFinalA.receipt.gasUsed);
          }
          break;
        }
        xab = res;
        const res3 = await sc.newOffer(
          0,
          xab.map((x) => Math.floor(x * 10000)),
          {
            from: alpha,
          }
        );
        proposalsGasUsage.push(res3.receipt.gasUsed);
      } else {
        console.log('b)');
        const res = interpretation(t, xab, constjBeta);
        console.log(t, ') - b - ', res);
        if (typeof res === 'boolean') {
          if (res) {
            const resFinalB = await sc.accept(0, {
              from: beta,
            });
            console.log('accept(): ', resFinalB.receipt.gasUsed);
          }
          break;
        }
        xba = res;
        const res4 = await sc.newOffer(
          0,
          xba.map((x) => Math.floor(x * 10000)),
          {
            from: beta,
          }
        );
        proposalsGasUsage.push(res4.receipt.gasUsed);
      }
    }
    let gasAvgProp = 0;
    for (const propG of proposalsGasUsage) {
      gasAvgProp += propG;
    }
    console.log('newOffer(): ', gasAvgProp / proposalsGasUsage.length);
  });

  it('negotiation 2', async () => {
    const sc = await Negotiation.deployed();
    const tmax = 100;
    const constjAlphaTemplate = {
      namej: 'pricex',
      weight: 1,
      minj: 146,
      maxj: 155,
      kj: 0.1,
      Vjdec: false,
    };
    const constjBetaTemplate = {
      namej: 'price',
      weight: 1,
      minj: 140,
      maxj: 149,
      kj: 0.1,
      Vjdec: true,
    };

    for (let issuesStep = 1; issuesStep <= 10; issuesStep++) {
      const constjAlpha = {
        tmax,
        beta: 0.99,
        constj: [],
      };
      const constjBeta = {
        tmax,
        beta: 1.5,
        constj: [],
      };
      constjAlphaTemplate.weight = 1 / issuesStep;
      constjBetaTemplate.weight = 1 / issuesStep;
      for (let issuesNum = 0; issuesNum < issuesStep; issuesNum++) {
        constjAlpha.constj.push(
          JSON.parse(JSON.stringify(constjAlphaTemplate))
        );
        constjBeta.constj.push(JSON.parse(JSON.stringify(constjBetaTemplate)));
      }

      const res1 = await sc.newNegotiation(beta, {
        from: alpha,
      });
      console.log('newNegotiation(): ', res1.receipt.gasUsed);

      // negotiation thread
      const negotiationGasUsage = res1.receipt.gasUsed;
      let acceptGasUsage = 0;
      const proposalsGasUsage = [];

      let xba = [];
      for (let j = 0; j < constjBeta.constj.length; j++) {
        console.log(sc.newOffer, sc.accept);
        xba.push(
          timeDependentTactic(
            0,
            constjBeta.tmax,
            constjBeta.beta,
            constjBeta.constj[j]
          )
        );
      }
      const res2 = await sc.newOffer(
        issuesStep - 1,
        xba.map((x) => Math.floor(x * 10000)),
        {
          from: beta,
        }
      );
      proposalsGasUsage.push(res2.receipt.gasUsed);
      let xab = [];
      for (let t = 1; t <= tmax + 1; t++) {
        if (t % 2) {
          const res = interpretation(t, xba, constjAlpha);
          if (typeof res === 'boolean') {
            if (res) {
              const resFinalA = await sc.accept(issuesStep - 1, {
                from: alpha,
              });
              acceptGasUsage = resFinalA.receipt.gasUsed;
              console.log('accept(): ', resFinalA.receipt.gasUsed);
            }
            break;
          }
          xab = res;
          const res3 = await sc.newOffer(
            issuesStep - 1,
            xab.map((x) => Math.floor(x * 10000)),
            {
              from: alpha,
            }
          );
          proposalsGasUsage.push(res3.receipt.gasUsed);
        } else {
          const res = interpretation(t, xab, constjBeta);
          if (typeof res === 'boolean') {
            if (res) {
              const resFinalB = await sc.accept(issuesStep - 1, {
                from: beta,
              });
              acceptGasUsage = resFinalB.receipt.gasUsed;
              console.log('accept(): ', resFinalB.receipt.gasUsed);
            }
            break;
          }
          xba = res;
          const res4 = await sc.newOffer(
            issuesStep - 1,
            xba.map((x) => Math.floor(x * 10000)),
            {
              from: beta,
            }
          );
          proposalsGasUsage.push(res4.receipt.gasUsed);
        }
      }
      let gasAvgProp = 0;
      for (const propG of proposalsGasUsage) {
        gasAvgProp += propG;
      }
      const finalGas = gasAvgProp / proposalsGasUsage.length;
      console.log('newOffer(): ', finalGas);

      fs.writeFileSync(
        filepath2,
        `${issuesStep},${negotiationGasUsage}, ${Math.floor(
          finalGas
        )}, ${acceptGasUsage}\n`,
        { flag: 'a' }
      );
    }
  });
});
