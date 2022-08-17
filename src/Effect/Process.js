'use strict';

import * as P from 'process';
import * as F from 'fs';

export const print = text => () => P.stdout.write(text);

export const printErr = text => () => P.stderr.write(text);

export const args = () => P.argv.slice(2);

export const exit = code => () => P.exit(code);

export const readFileImpl = left => right => name => () => {
  try {
    return right(F.readFileSync(name, { encoding: 'utf8' }));
  } catch (e) {
    return left(e.message);
  }
};
