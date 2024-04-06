import ArrayList from '@ohos.util.ArrayList';

export class ListAdapter<T> implements IDataSource {
    private listeners: ArrayList<DataChangeListener> = new ArrayList()
    private data: ArrayList<T> = new ArrayList()

    totalCount(): number {
        return this.data.length
    }

    isEmpty(): boolean {
        return this.data.length <= 0
    }

    getData(index: number): T {
        return this.data[index]
    }

    addData(data: T) {
        this.data.add(data)
        this.notifyDataAdd(this.data.length - 1)
    }

    addDataList(list: Array<T>) {
        list.forEach((data) => {
            this.addData(data)
        })
    }

    clear() {
        this.data.clear()
        this.notifyDataReload()
    }

    removeData(data: T) {
        let index = this.data.getIndexOf(data)
        if (index >= 0) {
            this.data.remove(data)
            this.notifyDataDelete(index)
        }
    }

    notifyDataAdd(index) {
        this.listeners.forEach((listener) => {
            listener.onDataAdd(index)
        })
    }

    notifyDataDelete(index: number) {
        this.listeners.forEach((listener) => {
            listener.onDataAdd(index)
        })
    }

    notifyDataReload() {
        this.listeners.forEach((listener) => {
            listener.onDataReloaded()
        })
    }

    registerDataChangeListener(listener: DataChangeListener) {
        if (!this.listeners.has(listener)) {
            this.listeners.add(listener)
        }
    }

    unregisterDataChangeListener(listener: DataChangeListener) {
        this.listeners.remove(listener)
    }
}