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
        label: 'Tenant Support',
        icon: 'i-heroicons-home',
        to: '/site-admin/tenant',
        title: 'Tenants',
      },
      {
        label: 'Tenant Residents',
        icon: 'i-heroicons-building-office',
        to: '/site-admin/tenant-residents',
        title: 'Tenant Residents',
      },
      {
        label: 'Site Users',
        icon: 'i-heroicons-users',
        to: '/site-admin/site-users',
        title: 'Site Users',
      },
      {
        label: 'License Packs',
        icon: 'i-heroicons-cog-6-tooth',
        to: '/site-admin/license-pack',
        title: 'License Packs',
      },
      {
        label: 'Applications',
        icon: 'i-heroicons-cog-6-tooth',
        to: '/site-admin/applications',
        title: 'Applications',
      },
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