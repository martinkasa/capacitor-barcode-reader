import { WebPlugin } from '@capacitor/core';
import { BarcodeReaderPluginPlugin } from './definitions';

export class BarcodeReaderPluginWeb extends WebPlugin implements BarcodeReaderPluginPlugin {
  constructor() {
    super({
      name: 'BarcodeReaderPlugin',
      platforms: ['web']
    });
  }

  async echo(options: { value: string }): Promise<{value: string}> {
    console.log('ECHO', options);
    return options;
  }
}

const BarcodeReaderPlugin = new BarcodeReaderPluginWeb();

export { BarcodeReaderPlugin };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(BarcodeReaderPlugin);
