import { WebPlugin } from "@capacitor/core";
import { BarcodeReaderPluginPlugin, BarcodeReaderResult } from "./definitions";

export class BarcodeReaderPluginWeb extends WebPlugin
  implements BarcodeReaderPluginPlugin {
  constructor() {
    super({
      name: "BarcodeReaderPlugin",
      platforms: ["web"]
    });
  }

  open(): Promise<BarcodeReaderResult> {
    throw new Error("Method not implemented.");
  }

  close(): Promise<void> {
    throw new Error("Method not implemented.");
  }
}

const BarcodeReaderPlugin = new BarcodeReaderPluginWeb();

export { BarcodeReaderPlugin };

import { registerWebPlugin } from "@capacitor/core";
registerWebPlugin(BarcodeReaderPlugin);
