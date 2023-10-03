<template>
  <UCard>
    <template #header>
      <h1 class="text-2xl font-bold">Tacos</h1>
    </template>
    <div>
      <p>
        Tacos are delicious. You can put anything you want on them.
      </p>
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
