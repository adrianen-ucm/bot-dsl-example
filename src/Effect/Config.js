'use strict';

import * as F from 'fs';

const configFile = './config.json';

export const readConfigImpl = left => right => () => {
  try {
    const { api_base_url } = JSON.parse(
      F.readFileSync(configFile, { encoding: 'utf8' })
    );

    if (api_base_url == null)
      return left('"api_base_url" not declared in config file');

    return right({
      apiBaseUrl: api_base_url
    });
  } catch (e) {
    return left(e.message);
  }
};
