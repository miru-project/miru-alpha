class Element {
  constructor(content, selector, className) {
    this.content = content;
    this.selector = selector || "";
    this.className = className;
  }

  async querySelector(selector, className) {
    return new Element(await this.execute(), selector, className);
  }

  async execute(fun) {
    return await handlePromise("querySelector" + this.className, JSON.stringify([this.content, this.selector, fun]));
  }

  async removeSelector(selector) {
    this.content = await handlePromise("removeSelector" + this.className, JSON.stringify([await this.outerHTML, selector]));
    return this;
  }

  async getAttributeText(attr) {
    return await handlePromise("getAttributeText" + this.className, JSON.stringify([await this.outerHTML, this.selector, attr]));
  }

  get text() {
    return this.execute("text");
  }

  get outerHTML() {
    return this.execute("outerHTML");
  }

  get innerHTML() {
    return this.execute("innerHTML");
  }
}

class XPathNode {
  constructor(content, selector, className) {
    this.content = content;
    this.selector = selector;
    this.className = className;
  }

  async execute(fun) {
    return await handlePromise("queryXPath" + this.className, JSON.stringify([this.content, this.selector, fun]));
  }

  get attr() {
    return this.execute("attr");
  }

  get attrs() {
    return this.execute("attrs");
  }

  get text() {
    return this.execute("text");
  }

  get allHTML() {
    return this.execute("allHTML");
  }

  get outerHTML() {
    return this.execute("outerHTML");
  }
}

// 重写 console.log
console.log = function (message) {
  if (typeof message === "object") {
    message = JSON.stringify(message);
  }
  DartBridge.sendMessage("miruLog", JSON.stringify([message.toString()]));
};

class Extension {
  constructor(extension) {
    this.extension = extension;
  }

  //package = this.extension.package;
  //name = this.extension.name;
  // 在 load 中注册的 keys
  settingKeys = [];

  querySelector(content, selector) {
    return new Element(content, selector, this.extension.className);
  }

  async request(url, options) {
    options = options || {};
    options.headers = options.headers || {};
    const miruUrl = options.headers["Miru-Url"] || this.extension.webSite;
    options.method = options.method || "get";
    const message = await handlePromise("request" + this.extension.className, JSON.stringify([miruUrl + url, options, this.extension.package]));
    try {
      return JSON.parse(message);
    } catch (e) {
      return message;
    }
  }

  queryXPath(content, selector) {
    return new XPathNode(content, selector, this.extension.className);
  }

  async querySelectorAll(content, selector) {
    const arg = await handlePromise("querySelectorAll" + this.extension.className, JSON.stringify({ content: content, selector: selector }));
    const message = JSON.parse(arg);
    const elements = [];
    for (const e of message) {
      elements.push(new Element(e, selector, this.extension.className));
    }
    return elements;
  }

  async getAttributeText(content, selector, attr) {
    const waitForChange = new Promise(resolve => {
      DartBridge.setHandler("getAttributeText" + this.extension.className, async (arg) => {
        resolve(arg);
      })
    });
    DartBridge.sendMessage("getAttributeText" + this.extension.className, JSON.stringify([content, selector, attr]));
    const elements = await waitForChange;
    return elements;
  }

  latest(page) {
    throw new Error("not implement latest");
  }

  search(kw, page, filter) {
    throw new Error("not implement search");
  }

  createFilter(filter) {
    throw new Error("not implement createFilter");
  }

  detail(url) {
    throw new Error("not implement detail");
  }

  watch(url) {
    throw new Error("not implement watch");
  }

  tags(url) {
    throw new Error("not implement watch");
  }

  checkUpdate(url) {
    throw new Error("not implement checkUpdate");
  }
  
  async getSetting(key) {
    return await handlePromise("getSetting" + this.extension.className, JSON.stringify([key]));
  }

  async registerSetting(settings) {
    console.log(JSON.stringify([settings]));
    this.settingKeys.push(settings.key);
    return await handlePromise("registerSetting" + this.extension.className, JSON.stringify([settings]));
  }

  async load() { }
}

async function handlePromise(channelName, message) {
  const waitForChange = new Promise(resolve => {
    DartBridge.setHandler(channelName, async (arg) => {
      resolve(arg);
    })
  });
  DartBridge.sendMessage(channelName, message);
  return await waitForChange
}

async function stringify(callback) {
  const data = await callback();
  return typeof data === "object" ? JSON.stringify(data, 0, 2) : data;
}