struct Index extends   {
    constructor() { }
    build() {
            .height('100%')
            .width('100%');
    }
}
class MyDataSource {
    constructor() {
        this.listeners = [];
        this.originDataArray = [];
    }
    unregisterDataChangeListener(listener) {
        const pos = this.listeners.indexOf(listener);
        if (pos >= 0) {
            console.info('remove listener');
            this.listeners.splice(pos, 1);
        }
    }
    registerDataChangeListener(listener) {
        if (this.listeners.indexOf(listener) < 0) {
            console.info('add listener');
            this.listeners.push(listener);
        }
    }
    getData(index) {
        return this.originDataArray[index];
    }
    totalCount() {
        return this.originDataArray.length;
    }
    // 通知LazyForEach组件需要重载所有子组件
    notifyDataReload() {
        this.listeners.forEach(listener => {
            listener.onDataReloaded();
        });
    }
    // 通知LazyForEach组件需要在index对应索引处添加子组件
    notifyDataAdd(index) {
        this.listeners.forEach(listener => {
            listener.onDataAdd(index);
        });
    }
    // 通知LazyForEach组件在index对应索引处数据有变化，需要重建该子组件
    notifyDataChange(index) {
        this.listeners.forEach(listener => {
            listener.onDataChange(index);
        });
    }
    // 通知LazyForEach组件需要在index对应索引处删除该子组件
    notifyDataDelete(index) {
        this.listeners.forEach(listener => {
            listener.onDataDelete(index);
        });
    }
    addData(index, data) {
        this.originDataArray.splice(index, 0, data);
        this.notifyDataAdd(index);
    }
    pushData(data) {
        this.originDataArray.push(data);
        this.notifyDataAdd(this.originDataArray.length - 1);
    }
}
export {};
//# sourceMappingURL=Index.js.map