import ArrayList from "@ohos.util.ArrayList"
import { MediaLogger } from './MediaLogger'

const TAG = "[ListAdapter]"

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

    addData(data: T, autoFlush: boolean = true) {
        try {
            this.data.add(data)
            if (autoFlush) {
                this.notifyDataAdd(this.data.length - 1)
            }
        } catch (error) {
            MediaLogger.attentionE(TAG, "Failed to add data: " + String(error))
        }
    }

    addDataWithIndex(data: T, index: number, autoFlush: boolean = true) {
        try {
            this.data.insert(data, index)
            if (autoFlush) {
                this.notifyDataAdd(index)
            }
        } catch (error) {
            MediaLogger.attentionE(TAG, "Failed to add data with index: " + String(error))
        }
    }

    addDataList(list: Array<T>, autoFlush: boolean = true) {
        list.forEach((data) => {
            this.addData(data, autoFlush)
        })
    }

    clear(autoFlush: boolean = true) {
        try {
            this.data.clear()
            if (autoFlush) {
                this.notifyDataReload()
            }
        } catch (error) {
            MediaLogger.attentionE(TAG, "Failed to clear data: " + String(error))
        }
    }

    removeData(data: T, autoFlush: boolean = true) {
        try {
            let index = this.data.getIndexOf(data)
            if (index >= 0) {
                this.data.remove(data)
                if (autoFlush) {
                    this.notifyDataDelete(index)
                }
            }
        } catch (error) {
            MediaLogger.attentionE(TAG, "Failed to remove data: " + String(error))
        }
    }

    notifyDataAdd(index: number) {
        try {
            this.listeners.forEach((listener) => {
                listener.onDataAdd(index)
            })
        } catch (error) {
            MediaLogger.attentionE(TAG, "Failed to notify data add: " + String(error))
        }
    }

    notifyDataDelete(index: number) {
        try {
            this.listeners.forEach((listener) => {
                listener.onDataDelete(index)
            })
        } catch (error) {
            MediaLogger.attentionE(TAG, "Failed to notify data delete: " + String(error))
        }
    }

    notifyDataReload() {
        try {
            this.listeners.forEach((listener) => {
                listener.onDataReloaded()
            })
        } catch (error) {
            MediaLogger.attentionE(TAG, "Failed to notify data reload: " + String(error))
        }
    }

    registerDataChangeListener(listener: DataChangeListener) {
        try {
            if (!this.listeners.has(listener)) {
                this.listeners.add(listener)
            }
        } catch (error) {
            MediaLogger.attentionE(TAG, "Failed to register data listener: " + String(error))
        }
    }

    unregisterDataChangeListener(listener: DataChangeListener) {
        try {
            this.listeners.remove(listener)
        } catch (error) {
            MediaLogger.attentionE(TAG, "Failed to unregister data listener: " + String(error))
        }
    }
}
