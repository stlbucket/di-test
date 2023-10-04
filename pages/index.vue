<template>
  <UCard>
    <template #header>
      <h1 class="Home Page">Function Bucket Proto</h1>
      <p>This is a prototype instance - all data is subject to removal at any time.</p>
      <p v-if="showDemoResidents">Since DEMO_MODE is enabled, the below users can be quickly logged in.</p>
    </template>
    <DemoResidents v-if="showDemoResidents" />
  </UCard>
</template>

<script lang="ts" setup>
const user = useSupabaseUser()
const showDemoResidents = computed(() => {
  return useRuntimeConfig().public.DEMO_MODE && useHasPermission(user.value, 'p:app-super-admin')
})
</script>
