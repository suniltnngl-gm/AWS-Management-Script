// @file frontend/components/ResourceCard.js
// @brief Reusable resource card component
// @description Vue component for displaying AWS resource metrics

const ResourceCard = {
    props: ['title', 'count', 'icon', 'color'],
    template: `
        <div class="resource-card" :style="{ borderLeft: '4px solid ' + color }">
            <div class="resource-header">
                <span class="resource-icon">{{ icon }}</span>
                <h3>{{ title }}</h3>
            </div>
            <div class="resource-count">{{ count || 0 }}</div>
            <div class="resource-status" :class="statusClass">
                {{ statusText }}
            </div>
        </div>
    `,
    computed: {
        statusClass() {
            return this.count > 0 ? 'active' : 'inactive';
        },
        statusText() {
            return this.count > 0 ? 'Active' : 'None';
        }
    }
};

// Register component globally
if (typeof Vue !== 'undefined') {
    Vue.component('resource-card', ResourceCard);
}