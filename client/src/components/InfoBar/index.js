import React, { Component } from 'react';
import styles from './InfoBar.module.scss';
import cx from 'classnames';

export default class InfoBar extends Component {
  render() {
    return (
      <div className={styles.InfoBar}>
        <div>InfoBar</div>
      </div>
    );
  }
}
