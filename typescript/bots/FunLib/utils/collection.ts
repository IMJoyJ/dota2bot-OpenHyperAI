// utils/collection.ts - Auto-generated sub-module


/**
 * Shuffle an array.
 * @param tbl - The array to shuffle.
 * @returns The shuffled array.
 */
export function Shuffle<T>(a: T[]): T[] {
    for (let i = a.length - 1; i > 0; i--) {
        const j = RandomInt(0, i); // inclusive
        const tmp = a[i];
        a[i] = a[j];
        a[j] = tmp;
    }
    return a;
}




/**
 * Deep copy an object.
 * @param orig - The object to copy.
 * @returns The copied object.
 */
export function Deepcopy<T extends ArrayLike<unknown>>(orig: T): T {
    const originalType = type(orig);
    let copy;
    if (originalType == "table") {
        copy = {} as T;
        for (const [key, value] of Object.entries(orig)) {
            // @ts-ignore
            copy[Deepcopy(key)] = Deepcopy(value);
        }
        setmetatable(copy as object, Deepcopy(getmetatable(orig) as any) as object);
    } else {
        // number, string, boolean, etc.
        copy = orig;
    }
    return copy;
}




export function CombineTablesUnique<T extends object>(tbl1: T, tbl2: T): any[] {
    const set = new Set();

    for (const [_, value] of Object.entries(tbl1)) {
        set.add(value);
    }
    for (const [_, value] of Object.entries(tbl2)) {
        set.add(value);
    }

    const result = [];
    for (const element of set) {
        result.push(element);
    }
    return result;
}




export function MergeLists<T>(a: T[], b: T[]): T[] {
    return a.concat(b);
}




export function RemoveValueFromTable<T>(arr: T[], valueToRemove: T, removeAll: boolean) {
    let i = 0;
    while (i < arr.length) {
        if (arr[i] === valueToRemove) {
            table.remove(arr, i + 1); // lua 1-based
            if (!removeAll) break;
        } else {
            i++;
        }
    }
}




export function SetContains(set: Record<string, boolean>, key: string): boolean {
    return !!set[key];
}


export function AddToSet(set: Record<string, boolean>, key: string): void {
    set[key] = true;
}


export function RemoveFromSet(set: Record<string, boolean>, key: string): void {
    delete set[key];
}




export function HasValue(set: any, value: any) {
    for (const [_, element] of ipairs(set)) {
        if (value == element) {
            return true;
        }
    }
    return false;
}




const magicTable: any = {};



export function NewTable(): any {
    const a = {};
    setmetatable(a, magicTable);
    return a;
}




export function ForEach(_: any, tb: any, action: Function) {
    for (const [key, value] of ipairs(tb)) {
        action(key, value);
    }
}




export function Remove_Modify(table_: any, item: any) {
    let filter = item;
    if (type(item) !== "function") {
        filter = (t: any) => t == item;
    }
    let i = 1;
    let d = table_.length;
    while (i <= d) {
        if (filter(table_[i])) {
            table.remove(table_, i);
            d--;
        } else {
            i++;
        }
    }
}


