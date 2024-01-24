import router from '@ohos.router';
import http from '@ohos.net.http';
import config from './config'

@Entry
@Component
struct Index {
  @State count: number = 0;
  @State messages: MyDataSource = new MyDataSource()
  @State userInput: string = ''
  @State isResponding: boolean = false
  private listScroller: Scroller = new Scroller();

  postMessage() {

    this.messages.pushData(new ChatMessage('user', this.userInput))
    this.userInput = ''
    this.listScroller.scrollToIndex(this.messages.totalCount() - 1)
    this.isResponding = true
    this.messages.pushData(
      new ChatMessage('assistant', ''
      ))
    let httpRequest = http.createHttp();
    // 用于订阅HTTP响应头，此接口会比request请求先返回。可以根据业务需要订阅此消息
    // 从API 8开始，使用on('headersReceive', Callback)替代on('headerReceive', AsyncCallback)。 8+
    httpRequest.on('headersReceive', (header) => {
      console.info('header: ' + JSON.stringify(header));
    });

    httpRequest.request(
      // 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定

      config.endpoint,
      {
        method: http.RequestMethod.POST, // 可选，默认为http.RequestMethod.GET
        // 开发者根据自身业务需要添加header字段
        header: config.useAzure ? {
                                    'Content-Type': 'application/json',
                                    'api-key': config.apiKey
                                  } : {
                                        'Content-Type': 'application/json',
                                        'Authorization': 'Bearer ' + config.apiKey
                                      }
      ,
        // 当使用POST请求时此字段用于传递内容
        extraData: {
          "messages": this.messages.getAllData(),
          "temperature": 0.7,
        },
        expectDataType: http.HttpDataType.OBJECT, // 可选，指定返回数据的类型
        usingCache: false, // 可选，默认为true
        priority: 1, // 可选，默认为1
        connectTimeout: 60000, // 可选，默认为60000ms
        readTimeout: 60000, // 可选，默认为60000ms
        //usingProtocol: http.HttpProtocol.HTTP1_1, // 可选，协议类型默认值由系统自动指定
      }, (err, data) => {
      if (!err) {
        console.log(JSON.stringify(data.result))
        this.isResponding = false
        this.messages.updateData(this.messages.totalCount() - 1,
          new ChatMessage('assistant',
            (data.result as any).choices[0].message.content
            // JSON.stringify(data.result)
          ))
        this.listScroller.scrollToIndex(this.messages.totalCount() - 1)
        // data.result为HTTP响应内容，可根据业务需要进行解析

      } else {

        this.isResponding = false
        this.messages.updateData(this.messages.totalCount() - 1,
          new ChatMessage('assistant',
            '服务出错了，请重试'
            // JSON.stringify(data.result)
          ))
        this.listScroller.scrollToIndex(this.messages.totalCount() - 1)
        console.info('error:' + JSON.stringify(err));
        // 取消订阅HTTP响应头事件
        httpRequest.off('headersReceive');
        // 当该请求使用完毕时，调用destroy方法主动销毁
        httpRequest.destroy();
      }
    }
    );

  }

  aboutToAppear() {
    this.postMessage.bind(this)
  }

  build() {
    Column({ space: 0 }) {

      Row() {
        Text()
        Text('ChatGPT')
          .fontWeight(FontWeight.Bold)
          .fontSize(20)

        Button() {
          Image($r('app.media.clear')).width(30).height(30)
        }
        .onClick(() => {
          this.messages.clearData()
        })
        .alignSelf(ItemAlign.Center)
        .backgroundColor('#0fff')

      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceAround)
      .height(60)
      .border({ width: { top: 0, bottom: 1 }, color: '#999' })
      .width('100%')

      List({ scroller: this.listScroller }) {
        LazyForEach(this.messages, (item) => {
          ListItem() {

            if (item.role == 'user') {
              Row() {
                Blank()
                  .width(55)
                Column() {
                  // Text('Me')
                  //   .fontWeight(FontWeight.Bold)
                  //   .textAlign(TextAlign.End)
                  //   .width('100%')
                  Text(item.content)
                    .fontSize(18)
                    .textAlign(TextAlign.Start)
                    .width('100%')
                }
                .backgroundColor('#96ed6a')
                .layoutWeight(1)
                //.height(80)
                .padding(15)
                .margin({ right: 15 })
                .borderRadius(5)

                Button() {
                  Image($r('app.media.me'))
                    .width(40)
                    .height(40)
                }
                .type(ButtonType.Circle)
                .backgroundColor('#eee')
                .width(40)
                .height(40)
              }
              .justifyContent(FlexAlign.End)
              .padding(10)
              .alignItems(VerticalAlign.Top)
              .width('100%')
            } else {
              Row() {
                Button() {
                  Image($r('app.media.chatgpticon'))
                    .width(40)
                    .height(40)
                }
                .type(ButtonType.Circle)
                .width(40)
                .height(40)

                Column() {
                  // Text('ChatGPT')
                  //     .fontWeight(FontWeight.Bold)
                  //     .textAlign(TextAlign.Start)
                  //     .width('100%')
                  if (this.isResponding && !item.content.length) {
                    LoadingProgress()
                      .color(Color.Gray)
                      .width(40)
                      .height(40)
                  } else {
                    Text(item.content)
                      .fontSize(18)
                      .textAlign(TextAlign.Start)
                      .width('100%')
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .backgroundColor('#fff')
                .layoutWeight(1)
                //.height(80)
                .padding(15)
                .margin({ left: 15 })
                .borderRadius(5)

                Blank()
                  .width(55)
              }
              .alignItems(VerticalAlign.Top)
              .padding(10)
              .width('100%')
            }


          }

        })

      }
      .layoutWeight(1)
      .cachedCount(3)
      // .divider({
      //   strokeWidth: 1,
      //   startMargin: 5,
      //   endMargin: 5,
      //   color: '#ffe9f0f0'
      // })
      .scrollBar(BarState.Auto)
      //.backgroundColor('#eee')


      Row() {
        TextInput({ placeholder: "Let's talk", text: this.userInput })
          .placeholderColor('#999')
          .layoutWeight(1)
          .onChange((value: string) => {
            console.info(value);
            this.userInput = value;
          })
          .onSubmit((EnterKeyType) => {
            this.postMessage()

          })
        Button('Send')
          .backgroundColor(0x317aff)
          .margin({ left: 10 })
          .width(60)
          .height(30)

          .onClick(() => {
            if (this.userInput && !this.isResponding) {
              this.postMessage()
            }
          })
      }
      .margin({ bottom: 10 })
      .borderWidth({ top: 1 })
      .borderColor('#999')
      .padding(10)
      .width('100%')
      .height(60)

    }

    .backgroundColor('#eee')
    .height('100%')
    .width('100%')
  }
}

class ChatMessage {
  public role: string
  public content: string | string[]

  constructor(role: string, contnet: string | string[]) {
    this.role = role
    this.content = contnet
  }
}

class MyDataSource implements IDataSource {
  private systemMsg = new ChatMessage('assistant', '我是AI智能客服，有什么问题可以帮你？')
  private listeners: DataChangeListener[] = [];
  private originDataArray: ChatMessage[] = [this.systemMsg];

  public getAllData(): ChatMessage[] {
    return this.originDataArray;
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  getData(index: number) {
    return this.originDataArray[index];
  }

  totalCount(): number {
    return this.originDataArray.length;
  }
  // 通知LazyForEach组件需要重载所有子组件
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  // 通知LazyForEach组件需要在index对应索引处添加子组件
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  // 通知LazyForEach组件在index对应索引处数据有变化，需要重建该子组件
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  // 通知LazyForEach组件需要在index对应索引处删除该子组件
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  public addData(index: number, data: ChatMessage): void {
    this.originDataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: ChatMessage): void {
    this.originDataArray.push(data);
    this.notifyDataAdd(this.originDataArray.length - 1);
  }

  public updateData(index: number, data: ChatMessage): void {
    this.originDataArray[index].content = data.content;
    this.notifyDataChange(index)
  }

  public clearData(): void {
    this.originDataArray = [this.systemMsg]
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }
}




