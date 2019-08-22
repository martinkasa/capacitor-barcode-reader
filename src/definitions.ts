declare module "@capacitor/core" {
  interface PluginRegistry {
    BarcodeReaderPlugin: BarcodeReaderPluginPlugin;
  }
}

export type BarcodeReaderFoundResult = {
  action: "found";
  value: string;
};

export type BarcodeReaderClosedResult = {
  action: "closed";
};

export type BarcodeReaderResult =
  | BarcodeReaderFoundResult
  | BarcodeReaderClosedResult;

export interface BarcodeReaderPluginPlugin {
  open(): Promise<BarcodeReaderResult>;
  close(): Promise<void>;
}
