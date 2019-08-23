import React, { Component } from 'react';
import { Button } from 'rimble-ui';
import styles from './Instructions.module.scss';

export default class Instructions extends Component {
  renderCounterSetup() {
    return (
      <div className={styles.instructions}>
        <h2> Build your first app with Starter Kit Tutorial </h2>
        <div className={styles.step}>
          <div className={styles.instruction}>Initialize your OpenZeppelin SDK project</div>
          <div className={styles.code}>
            <code>openzeppelin init {'<<your project name>>'}</code>
          </div>
        </div>
        <div className={styles.step}>
          <div className={styles.instruction}>
            Create an instance of the Counter contract and deploy it using the create command, follow the cli prompts.
          </div>
          <div className={styles.code}>
            <code>openzeppelin create Counter</code>
          </div>
        </div>
        <div className={styles.step}>
          <div className={styles.instruction}>
            Done! Refresh the page to interact with your instance of the counter contract.
          </div>
          <div className={styles.instruction}>
            Learn more about <a href="https://openzeppelin.com/sdk/">OpenZeppelin SDK</a> or ask a question in the{' '}
            <a href="https://forum.openzeppelin.com">Forum</a>.
          </div>
          <br />
          <Button onClick={() => window.location.reload()}>Reload</Button>
        </div>
      </div>
    );
  }

  renderSetup() {
    return (
      <div className={styles.instructions}>
        <h1> Starter Kit Tutorial is running! </h1>
        <div className={styles.step}>
          <div className={styles.instruction}>Congratulations! Your application is correctly setup.</div>
        </div>

        <div className={styles.step}>
          <div className={styles.instruction}>
            Visit the tutorials. Start with the <a href="/counter"> Counter</a> page to deploy and interact with your
            first contract.
          </div>
        </div>
      </div>
    );
  }

  renderMetamask() {
    const code = this.props.accounts[0];
    return (
      <div className={styles.instructions}>
        <h2> Fund your Metamask account </h2>
        <p> You need some ETH to be able to send transactions. </p>
        <div className={styles.step}>
          <div className={styles.instruction}>1. Open a terminal and type</div>
          <div className={styles.code}>
            <code>openzeppelin transfer</code>
          </div>
        </div>
        <div className={styles.step}>
          <div className={styles.instruction}>
            2. Send 0.5 ETH from one of your ganache accounts to your Metamask account.
          </div>
          <div className={styles.code}>
            <code>{code}</code>
          </div>
        </div>
        <div className={styles.step}>
          <div className={styles.instruction}>
            3. Congratulations!! You can now interact with the contract and increase the counter.
          </div>
        </div>
      </div>
    );
  }

  renderUpgrade() {
    return (
      <div className={styles.instructions}>
        <h2> Upgrading your contract </h2>
        <p> Thanks to OpenZeppelin SDK, you can upgrade the code of your contract to add more functionality. </p>
        <div className={styles.step}>
          <div className={styles.instruction}>
            1. Open <span>contracts/Counter.sol</span> and uncomment the decreaseCounter method (lines 32-36).
          </div>
          <div className={styles.code}>
            <code>{`// function decreaseCounter(uint256 amount) public returns (bool) {`}</code>
          </div>
        </div>
        <div className={styles.step}>
          <div className={styles.instruction}>
            2. Save the changes and compile, push, and update the new changes to the network.
          </div>
          <div className={styles.code}>
            <code>openzeppelin update Counter</code>
          </div>
        </div>
        <div className={styles.step}>
          <div className={styles.instruction}>
            3. Congratulations! You have upgraded your contract and you can now decrease the counter.
          </div>
          <br />
          <Button onClick={() => window.location.reload()}>Reload</Button>
        </div>
      </div>
    );
  }

  renderAutoUpgrade() {
    return (
      <div className={styles.instructions}>
        <h2> Upgrading on Development Network </h2>
        <p>
          {' '}
          Thanks to OpenZeppelin SDK and Solidity Loader your smart contracts would reload automatically after you save
          a .sol file while preserving a state.{' '}
        </p>
        <div className={styles.step}>
          <div className={styles.instruction}>
            1. Open <span>contracts/Counter.sol</span> and uncomment the decreaseCounter method (lines 32-36).
          </div>
          <div className={styles.code}>
            <code>{`// function decreaseCounter(uint256 amount) public returns (bool) {`}</code>
          </div>
        </div>
        <div className={styles.step}>
          <div className={styles.instruction}>
            2. Save the changes and wait for the .sol files to compile. Upon completion, Solidity Loader will push and
            update your smart contracts
          </div>
        </div>
        <div className={styles.step}>
          <div className={styles.instruction}>
            3. Congratulations! You have upgraded your contract and you can now decrease the counter.
          </div>
        </div>
        <div className={styles.separator} />
        <p>
          {' '}
          * On a non development network you would have to run <strong>openzeppelin update</strong> command manually.{' '}
        </p>
      </div>
    );
  }

  renderFAQ() {
    return (
      <div className={styles.instructions}>
        <h2> FAQ </h2>
        <div className={styles.question}>Q: How do I deploy to other networks?</div>
        <div className={styles.separator} />
        <div className={styles.step}>
          <div className={styles.instruction}>
            1. Enter the mnemonic of the account you want to use to deploy in the{' '}
            <span className={styles.inline}> .env</span> file located in the top level folder. Add your network to the{' '}
            <span className={styles.inline}>networks.js</span> file.
          </div>
          <div className={styles.code}>
            <code>mnemonic='fill'</code>
          </div>
        </div>
        <div className={styles.step}>
          <div className={styles.instruction}>3. Push the project contracts and deploy the dependencies (if any).</div>
          <div className={styles.code}>
            <code>openzeppelin push </code>
          </div>
        </div>
        <div className={styles.step}>
          <div className={styles.instruction}>
            4. Create the instances and follow the <span className={styles.inline}>cli</span> prompts
          </div>
          <div className={styles.code}>
            <code>openzeppelin create CONTRACT_NAME </code>
          </div>
        </div>
        <div className={styles.question}>Q: How do I run tests?</div>
        <div className={styles.separator} />
        <div className={styles.step}>
          <div className={styles.instruction}>1. To execute smart contract tests run:</div>
          <div className={styles.code}>
            <code>truffle test</code>
          </div>
        </div>
        <div className={styles.step}>
          <div className={styles.instruction}>2. To test your React components, (inside the client folder) run:</div>
          <div className={styles.code}>
            <code>npm run test</code>
          </div>
        </div>
        <div className={styles.question}>Q: How do I connect to other networks from my local website?</div>
        <div className={styles.separator} />
        <div className={styles.step}>
          <div className={styles.instruction}>
            1. Change the fallback provider by switching <span className={styles.inline}> REACT_APP_NETWORK </span>{' '}
            inside the .env file located in the client folder.
          </div>
          <div className={styles.code}>
            <code>REACT_APP_NETWORK = https://mainnet.infura.io/v3/d6760e62b67f4937ba1ea2691046f06d</code>
          </div>
        </div>
        <div className={styles.step}>
          Take into account that this only switches the default provider. If you are using Metamask, you only need to
          switch network from the extension.
        </div>
      </div>
    );
  }

  getDefaultAddress() {
    const { ganacheAccounts } = this.props;
    return (ganacheAccounts && ganacheAccounts.length) > 2 ? ganacheAccounts[2] : '<ADDRESS>';
  }

  render() {
    const { name } = this.props;
    switch (name) {
      case 'setup':
        return this.renderSetup();
      case 'metamask':
        return this.renderMetamask();
      case 'upgrade':
        return this.renderUpgrade();
      case 'upgrade-auto':
        return this.renderAutoUpgrade();
      case 'counter':
        return this.renderCounterSetup();
      case 'faq':
        return this.renderFAQ();
      case 'evm':
        return this.renderEVM();
      default:
        return this.renderSetup();
    }
  }
}
