import React from 'react';
import styles from './header.module.scss';
import WordForm from '../WordForm';

const Header = props => (
  <div className={styles.header}>
    <nav id="menu" className="menu">
      <div className={styles.brand}>
        <div className={styles.blackText}>WordDao</div>
      </div>
    </nav>
    <WordForm {...props} />
  </div>
);

export default Header;
