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
           <el-button v-if="wf.clazz == 'start'" @click="start" type="primary">启动</el-button>
           <!-- complete传入流转参数 决定下一步会流转到什么位置 此处可以设置多个按钮来做不同的流转 -->
           <el-button v-if="canShow" @click="complete('yes')" type="primary">提交</el-button>
           <el-button v-if="showSelfNode" @click="complete('')" type="primary">确认</el-button>
           <el-button @click="back" type="primary">返回</el-button>
           </el-form-item>
    </el-form>
</div>
</template>

<script>
import {
    startWorkflow,
    completeWorkflowMove
} from "@/api/workflowProcess";
import { infoList } from "@/mixins/infoList";
import { useStore } from "vuex";
import { useRouter,useRoute } from "vue-router"
import { ref,reactive,getCurrentInstance,computed } from "vue"
export default {
  name: "{{.StructName}}",
  props:{
      business:{
         type:Object,
        default:function(){return null}
      },
      wf:{
        type:Object,
        default:function(){return{}}
      },
      move:{
         type:Object,
         default:function(){return{}}
      },
      workflowMoveID:{
        type:[Number,String],
        default:0
      }
   },
   setup(props){
      const {ctx} getCurrentInstance()
      const router = useRouter()
      const route = useRoute()
      const { getDictFun } = infoList();
      const type = ref("");
      {{- range .Fields}}
          {{- if .DictType }}
           const {{ .DictType }}Options = reactive([]);
          {{ end -}}
      {{end -}}
      const  formData = reactive({
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
      const userInfo =  computed(()=>store.getters["user/userInfo"])
      const showSelfNode = computed(()=>{
        if(props.wf.assignType == "self" && props.move.promoterID == userInfo.value.ID){
          return true
        }else{
          return false
        }
      })
      const canShow = computed(()=>{
        if(props.wf.assignType == "user"){
           if(props.wf.assignValue.indexOf(","+userInfo.value.ID+",")>-1 && props.wf.clazz == 'userTask'){
              return true
           }else{
              return false
           }
        }else if(props.wf.assign_type == "authority"){
           if(props.wf.assignValue.indexOf(","+userInfo.value.authorityId+",")>-1 && props.wf.clazz == 'userTask'){
              return true
           }else{
              return false
           }
        }
     })
     const start = async () => {
           const res = await startWorkflow({
                 business:formData,
                 wf:{
                   workflowMoveID:props.workflowMoveID,
                   businessId:0,
                   businessType:"{{.Abbreviation}}",
                   workflowProcessID:props.wf..workflowProcessID,
                   workflowNodeID:props.wf.id,
                   promoterID:userInfo.value.ID,
                   operatorID:userInfo.value.ID,
                   action:"create",
                   param:""
                   }
               });
           if (res.code == 0) {
             ctx.$message({
               type:"success",
               message:"启动成功"
             })
            back()
           }
         }
        const complete = async (param) =>{
          const res = await completeWorkflowMove({
                 business:formData,
                 wf:{
                   workflowMoveID:props.workflowMoveID,
                   businessID:formData.ID,
                   businessType:"{{.Abbreviation}}",
                   workflowProcessID:props.wf.workflowProcessID,
                   workflowNodeID:props.wf.id,
                   promoterID:userInfo.value.ID,
                   operatorID:userInfo.value.ID,
                   action:"complete",
                   param:param
                   }
          })
          if(res.code == 0){
            ctx.$message({
               type:"success",
               message:"提交成功"
            })
            back()
          }
         }
         const back = () =>{
             router.go(-1)
         }
        if(props.business){
        Object.assign(formData,props.business)
       }
       return {
       formData,
       start,
       canShow,
       showSelfNode,
       complete,
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