import React from 'react';
import styles from './header.module.scss';
import Hero from '../Hero';

const Header = props => (
  <div className={styles.header}>
    <nav id="menu" className="menu">
      <div className={styles.brand}>
        <div className={styles.blackText}>WordDao</div>
      </div>
    </nav>
    <Hero {...props} />
  </div>
);

export default Header;
