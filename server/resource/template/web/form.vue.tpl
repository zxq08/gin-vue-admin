<template>
<div>
    <el-form :model="formData" label-position="right" label-width="80px">
        {{- range .Fields}}
             <el-form-item label="{{.FieldDesc}}:">
          {{- if eq .FieldType "bool" }}
                <el-switch active-color="#13ce66" inactive-color="#ff4949" active-text="是" inactive-text="否" v-model="formData.{{.FieldJson}}" clearable ></el-switch>
          {{ end -}}
          {{- if eq .FieldType "string" }}
                <el-input v-model="formData.{{.FieldJson}}" clearable placeholder="请输入" ></el-input>
          {{ end -}}
          {{- if eq .FieldType "int" }}
          {{- if .DictType}}
                 <el-select v-model="formData.{{ .FieldJson }}" placeholder="请选择" clearable>
                     <el-option v-for="(item,key) in {{ .DictType }}Options" :key="key" :label="item.label" :value="item.value"></el-option>
                 </el-select>
          {{ else -}}
                 <el-input v-model.number="formData.{{ .FieldJson }}" clearable placeholder="请输入"></el-input>
          {{ end -}}
          {{ end -}}
          {{- if eq .FieldType "time.Time" }}
                  <el-date-picker type="date" placeholder="选择日期" v-model="formData.{{ .FieldJson }}" clearable></el-date-picker>
           {{ end -}}
           {{- if eq .FieldType "float64" }}
                  <el-input-number v-model="formData.{{ .FieldJson }}" :precision="2" clearable></el-input-number>
           {{ end -}}
              </el-form-item>
           {{ end -}}

           <el-form-item>
           <el-button @click="save" type="primary">保存</el-button>
           <el-button @click="back" type="primary">返回</el-button>
           </el-form-item>
    </el-form>
</div>
</template>

<script>
import {
    create{{.StructName}},
    update{{.StructName}},
    find{{.StructName}}
} from "@/api/{{.PackageName}}";  //  此处请自行替换地址
import { infoList } from "@/mixins/infoList";
import { ref,reactive,getCurrentInstance } from "vue"
import { useRouter,useRoute } from "vue-router"
export default {
  name: "{{.StructName}}",
  setup(){
    const {ctx} = getCurrentInstance();
    const router = useRouter();
    const route = useRoute();
    const { getDictFun } = infoList();
    const type = ref("");
    {{- range .Fields}}
        {{- if .DictType }}
         const {{ .DictType }}Options = reactive([]);
        {{ end -}}
    {{end -}}
    const  formData = reactive({
           ID:0,
           CreatedAt:undefined,
           UpdatedAt:undefined,
          {{range .Fields}}
          {{- if eq .FieldType "bool" -}}
             {{.FieldJson}}:false,
          {{ end -}}
          {{- if eq .FieldType "string" -}}
             {{.FieldJson}}:"",
          {{ end -}}
          {{- if eq .FieldType "int" -}}
             {{.FieldJson}}:0,
          {{ end -}}
          {{- if eq .FieldType "time.Time" -}}
             {{.FieldJson}}:new Date(),
          {{ end -}}
          {{- if eq .FieldType "float64" -}}
             {{.FieldJson}}:0,
          {{ end -}}
          {{ end }}
    })
        const save = async () => {
          let res;
          switch (type.value) {
            case "create":
              res = await create{{.StructName}}(formData);
              break;
            case "update":
              res = await update{{.StructName}}(formData);
              break;
            default:
              res = await create{{.StructName}}(formData);
              break;
            }
            if (res.code == 0) {
              ctx.$message({
                type:"success",
                message:"创建/更改成功"
              })
            }
          }
          const back = () => {
            router.go(-1)
          }
          const initFunc = async () => {
          // 建议通过url传参获取目标数据ID 调用 find方法进行查询数据操作 从而决定本页面是create还是update 以下为id作为url参数示例
            if(route.query.id){
               const res = await find{{.StructName}}({ ID: route.query.id })
               if(res.code == 0){
                 Object.assign(formData,res.data.re{{.Abbreviation}})
                 type.value == "update"
               }
            }else{
               type.value == "create"
            }
              {{ range .Fields -}}
                {{- if .DictType }}
                Object.assign({{ .DictType }}Options,await getDictFun("{{.DictType}}"))
                {{ end -}}
              {{- end }}
            }
        initFunc()
        return {
          formData,
          save,
          back,
          {{ range .Fields -}}
            {{- if .DictType }}
             {{ .DictType }}Options,
            {{ end -}}
          {{- end }}
        }
  }

};
</script>

<style>
</style>