import { getDict } from "@/utils/dictionary";
import { reactive, ref } from "vue"
export const infoList = (listApi) => {
    const page = ref(1)
    const total = ref(10)
    const pageSize = ref(10)
    const tableData = reactive([])
    const searchInfo = reactive({})

    const filterDict = (value, options) => {
        const rowLabel = options.filter(item => item.value == value)
        return rowLabel && rowLabel[0] && rowLabel[0].label
    }
    const getDict = async(type) => {
        const dicts = await getDict(type)
        return dicts
    }

    const handleSizeChange = (val) => {
        pageSize.value = val
        getTableData()
    }

    const handleCurrentChange = (val) => {
        page.value = val
        getTableData()
    }

    const getTableData = async() => {
        const res = await listApi({ page: page.value, pageSize: pageSize.value, ...searchInfo })
        if (res.code == 0) {
            tableData.value = res.data.list
            total.value = res.data.total
            page.value = res.data.page
            pageSize.value = res.data.pageSize
        }
    }
    return {
        page,
        total,
        pageSize,
        tableData,
        searchInfo,
        filterDict,
        getDict,
        handleSizeChange,
        handleCurrentChange,
        getTableData,
    }
}