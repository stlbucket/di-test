<template>
  <UVerticalNavigation :links="links" />
</template>

<script lang="ts" setup>
  const user = useSupabaseUser()
  const appStateStore = useAppStateStore()
  const collapsed = computed(() => {
    return appStateStore.navCollapsed
  })

  const links = computed(() => {
    return [
      {
        label: 'Address Book',
        icon: 'i-heroicons-book-open',
        to: '/tools/address-book',
        title: 'Address Book',
      }
    ]
    .map((l: any) => {
      return {
        ...l,
        label: collapsed.value ? '' : l.label
      }
    })
    .filter((l:any) => useHasPermission(user, l.permissionKey))
  })
</script>