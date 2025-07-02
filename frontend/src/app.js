// @file frontend/src/app.js
// @brief Vue.js application for AWS Management Dashboard
// @description Frontend logic for AWS resource management

const { createApp } = Vue;

const API_BASE = 'http://localhost:5000/api';

createApp({
    data() {
        return {
            loading: false,
            error: null,
            message: null,
            resources: null,
            billing: null,
            mfaToken: '',
            awsProfile: 'default',
            mfaResult: null,
            auditResult: null
        }
    },
    
    methods: {
        async apiCall(endpoint, options = {}) {
            this.error = null;
            this.loading = true;
            
            try {
                const response = await axios({
                    url: `${API_BASE}${endpoint}`,
                    timeout: 30000,
                    ...options
                });
                
                if (response.data.success) {
                    return response.data;
                } else {
                    throw new Error(response.data.error || 'API call failed');
                }
            } catch (error) {
                this.error = error.message || 'Network error';
                throw error;
            } finally {
                this.loading = false;
            }
        },
        
        async loadResources() {
            try {
                const result = await this.apiCall('/resources');
                // Parse shell script output for resource counts
                const output = result.output || '';
                this.resources = {
                    ec2_count: this.extractCount(output, 'EC2 Instances'),
                    s3_count: this.extractCount(output, 'S3 Buckets'),
                    lambda_count: this.extractCount(output, 'Lambda Functions')
                };
                this.message = 'Resources loaded successfully';
            } catch (error) {
                console.error('Failed to load resources:', error);
            }
        },
        
        async loadBilling() {
            try {
                const result = await this.apiCall('/billing');
                const output = result.output || '';
                const costMatch = output.match(/Total Cost: \$?([\d.]+)/);
                this.billing = {
                    amount: costMatch ? parseFloat(costMatch[1]) : 0,
                    currency: 'USD'
                };
                this.message = 'Billing data loaded';
            } catch (error) {
                console.error('Failed to load billing:', error);
            }
        },
        
        async generateMFA() {
            if (!this.mfaToken) {
                this.error = 'MFA token is required';
                return;
            }
            
            try {
                const result = await this.apiCall('/mfa', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    data: {
                        token: this.mfaToken,
                        profile: this.awsProfile || 'default'
                    }
                });
                
                this.mfaResult = result.output;
                this.message = 'MFA credentials generated';
                this.mfaToken = '';
            } catch (error) {
                console.error('Failed to generate MFA:', error);
            }
        },
        
        async runAudit() {
            try {
                const result = await this.apiCall('/audit/cloudfront');
                this.auditResult = result.output;
                this.message = 'Security audit completed';
            } catch (error) {
                console.error('Failed to run audit:', error);
            }
        },
        
        extractCount(text, service) {
            const regex = new RegExp(`${service}\\s*:\\s*(\\d+)`);
            const match = text.match(regex);
            return match ? parseInt(match[1]) : 0;
        },
        
        clearMessages() {
            setTimeout(() => {
                this.error = null;
                this.message = null;
            }, 5000);
        }
    },
    
    watch: {
        error() { this.clearMessages(); },
        message() { this.clearMessages(); }
    },
    
    mounted() {
        this.loadResources();
    }
}).mount('#app');