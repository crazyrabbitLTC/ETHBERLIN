import React from 'react';
import styles from './Hero.module.scss';
import WordForm from './WordForm';

function Hero(props) {
  return (
    <div className={styles.Hero}>
      <WordForm {...props} />
    </div>
  );
}

export default Hero;
