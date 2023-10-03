<template>
  <UCard>
    <template #header>
      <h1 class="Home Page">Tacos</h1>
      <p>This is a prototype instance - all data is subject to removal at any time.</p>
    </template>
    <div>
    </div>
  </UCard>
  <DemoResidents />
  <!-- <DemoResidents v-if="environment === 'development'"  /> -->
</template>

<script lang="ts" setup>
  // const environment = computed(() => {
  //   return process.env.NODE_ENV
  // })
</script>
