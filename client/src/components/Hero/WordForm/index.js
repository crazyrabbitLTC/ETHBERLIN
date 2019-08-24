import React, { useState, useEffect } from 'react';
import styles from './WordForm.module.scss';
import axios from 'axios';
import { Field, Form, Input, Box, Button } from 'rimble-ui';

function WordForm(props) {
  const { wordDaoInstance, lib, accounts } = props;
  const [state, setState] = useState({ validated: false, word: '' });
  const [subState, setSubState] = useState({
    word: '',
    isAlreadyRegistered: false,
    signature: '',
    notAvailable: undefined,
  });

  const fetchSignature = async word => {
    let res = await axios.get(`http://localhost:3000/${word}`);
    const signature = res.data;
    return signature;
  };

  const claimWord = async (word, signature) => {
    let result;
    try {
      result = await wordDaoInstance.methods.addWord(word, signature).send({ from: accounts[0], value: 20 });
      console.log('REsult for Send: ', result);
    } catch (error) {
      console.log(error);
    }
  };

  const checkIfAvailable = async word => {
    let result;
    try {
      result = await wordDaoInstance.methods.wordExists(word).call();
    } catch (error) {
      console.log(error);
    }

    return result;
  };

  const handleSubmit = e => {
    e.preventDefault();

    const registerFlow = async word => {
      const isAlreadyRegistered = await checkIfAvailable(word);
      console.log('Word: ', word, ' is alreadyReadyRegistered: ', isAlreadyRegistered);

      let signature;
      let claim;
      if (!isAlreadyRegistered) {
        try {
          signature = await fetchSignature(word);
          claim = await claimWord(word, signature);
        } catch (error) {
          console.log(error);
        }
        console.log('word: ', word, ' Signature: ', signature);
        setSubState({ ...subState, word, signature, isAlreadyRegistered, notAvailable: false });
      } else {
        setSubState({ ...subState, word, notAvailable: true });
      }
    };

    registerFlow(state.word);
  };

  const handleValidation = e => {
    e.target.parentNode.classList.add('was-validated');
    let word = e.target.value;
    word = word.toLowerCase();
    setState({ validated: true, word });
  };

  return (
    <div className={styles.bar}>
      <div className={styles.word}>Check and Submit Word: </div>
      <Form className={styles.row} onSubmit={handleSubmit}>
        <Form.Field className={styles.inputBox} validated={state.validated} width={1}>
          <Form.Input type="text" required width={1} onChange={handleValidation} />
        </Form.Field>
        <Button className={styles.button} size="small" type="submit" width={1}>
          Sign Up
        </Button>
      </Form>
    </div>
  );
}

export default WordForm;
